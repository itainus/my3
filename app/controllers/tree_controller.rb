class TreeController < ApplicationController

  before_filter :init

  def init
    Rails.logger.info "[DEBUG INFO] ############## TreeController - init ##############"
    tree_id = params[:id]
    tree = current_user.trees.find(tree_id)

    if tree.blank?
      e = {
          error: "tree #{tree_id} is not owned by user #{current_user.id}"
      }
      render json: e.as_json
    end

    @tree = tree
  end

  def index
    Rails.logger.info "[DEBUG INFO] ############## TreeController - index ##############"

    Rails.logger.info @tree.as_json(include: {categories: {only: [:id, :name, :category_id]}, links: {only: [:id, :url, :category_id, :name]}})

     # render json: @tree.as_json(include: {categories: {only: [:id, :name, :category_id]}, links: {only: [:id, :url, :category_id, :name]}})
    render_tree
  end

  def create_new_category
    category_name = params[:category_name]
    category_parent_id = params[:category_parent_id]
    Rails.logger.info "[DEBUG INFO] ############## TreeController - create_new_category - category_name = #{category_name}, category_parent_id = #{category_parent_id} ##############"

    success = true
    branch = nil
    if category_name.blank? or category_parent_id.blank?
      Rails.logger.info "[DEBUG INFO] blank param"
      success = false
    else
      category = Category.create_if_not_exists(category_name, category_parent_id)
      branch = @tree.branch_category(category.id)
    end

    response = {
        :success => success,
        :branch => branch
    }

    render json: response.as_json
  end

  def add_category
    category_id = params[:category_id]
    Rails.logger.info "[DEBUG INFO] ############## TreeController - add_category - category_id = #{category_id} ##############"

    @tree.branch_category(category_id)

    render_tree
  end

  def add_branch
    branch_id = params[:branch_id]
    Rails.logger.info "[DEBUG INFO] ############## TreeController - add_branch - branch_id = #{branch_id} ##############"

    @tree.branch_fully(branch_id)

    render_tree
  end

  def remove_branch
    branch_id = params[:branch_id]
    Rails.logger.info "[DEBUG INFO] ############## TreeController - remove_branch - branch_id = #{branch_id} ##############"

    if @tree.branches.exists?(branch_id)
      @tree.branches.destroy(branch_id)
    else
      Rails.logger.info "[DEBUG INFO] branch '#{branch_id}' dose not exists"
    end

    render_tree
  end

  def create_new_link
    link_name = params[:link_name]
    link_url = params[:link_url]
    link_category_id = params[:link_category_id]
    link_img = params[:link_img]
    Rails.logger.info "[DEBUG INFO] ############## TreeController - create_new_link - link_name = #{link_name}, link_url = #{link_url}, link_category_id = #{link_category_id} ##############"
    # ix =open('http://cdn.sstatic.net/stackoverflow/img/favicon.ico')
    #  ii = open('http://cdn.sstatic.net/stackoverflow/img/favicon.ico', &:read)
    # ii = Base64.encode64(open('http://cdn.sstatic.net/stackoverflow/img/favicon.ico'){ |io| io.read })
    # ii = ActiveSupport::Base64.encode64(open(link_img) { |io| io.read })
    # Rails.logger.info ii
    # Rails.logger.info ii.as_json
    # Rails.logger.info "[DEBUG INFO] ############## TreeController - create_new_link - end ##############"

    if link_name.blank? or link_url.blank? or link_category_id.blank?
      Rails.logger.info "[DEBUG INFO] blank param"
      return render_tree
    end

    options = {
        :link_favicon_url => link_img
    }

    link = Link.create_if_not_exists(link_url, link_category_id, options)


    # linkImg = Base64.encode64(open(link_img){ |io| io.read })
    # src="data:image/png;base64,AAABA...."

    leaf = create_leaf(link, link_name)


    Rails.logger.info "[DEBUG INFO] tree = #{leaf.blank?}"
    render_tree
  end

  def add_link
    link_id = params[:link_id]
    link_name = params[:link_name]
    Rails.logger.info "[DEBUG INFO] ############## TreeController - add_link - link_id = #{link_id}, - link_name = #{link_name} ##############"

    if Link.exists?(link_id)
      link = Link.find(link_id)
      leaf = create_leaf(link, link_name)
    else
      Rails.logger.info "[DEBUG INFO] link '#{link_id}' dose not exists"
    end

    render_tree
  end

  def remove_leaf
    leaf_id = params[:leaf_id]
    Rails.logger.info "[DEBUG INFO] ############## TreeController - remove_leaf - leaf_id = #{leaf_id} ##############"

    if @tree.leaf_exists leaf_id
      leaf = Leaf.find(leaf_id)
      msg = {
          data: {
              title: "Follow Branch - leaf removed",
              body: "leaf '#{leaf.name}' was just removed from branch '#{leaf.branch.category.name}'"
          }
      }
      leaf.branch.notify_followers msg

      Leaf.destroy(leaf_id)
    else
      Rails.logger.info "[DEBUG INFO] leaf '#{leaf_id}' dose not exists"
    end

    render_tree
  end

  def update_leaf
    leaf_id = params[:leaf_id]
    link_name = params[:link_name]
    link_url = params[:link_url]
    link_category_id = params[:link_category_id]
    Rails.logger.info "[DEBUG INFO] ############## TreeController - update_leaf - leaf_id = #{leaf_id} - new link_name = #{link_name}, new link_url = #{link_url}, new link_category_id = #{link_category_id}##############"

    if @tree.leaf_exists(leaf_id)
      link = Link.create_if_not_exists(link_url, link_category_id, nil)
      branch = @tree.branches.where(:category_id => link_category_id).first
      Leaf.update(leaf_id, :name => link_name, :branch_id => branch.id, :link_id => link.id)
    else
      Rails.logger.info "[DEBUG INFO] leaf '#{leaf_id}' dose not exists"
    end

    render_tree
  end

  def suggest_branch
    link_url = params[:link_url]
    Rails.logger.info "[DEBUG INFO] ############## TreeController - suggest_branch - url = #{link_url}"
    cats = Link.suggest_categories(link_url)

    if cats.first.present?
      category = Category.find(cats.first.first)
      Rails.logger.info "[DEBUG INFO] ############## TreeController - suggest_branch - done - category_id = #{category.id} - name = #{category.name}"
      render json: category
    else
      Rails.logger.info "[DEBUG INFO] ############## TreeController - suggest_branch - done - no suggest"
      render json: {}
    end
  end

  private

    def notify_user(msg)
      # WebsocketRails[:tree].trigger 'update', msg
      # WebsocketRails.users[current_user.id].send_message :update, msg, :namespace => :tree
      NotificationsController.notify_user(current_user.id, msg)
    end

    def render_tree
      render json: @tree.as_json
    end

    def render_branches
      render json: @tree.branches.as_json(
        only: [:id],
        include: {
          category: {
            only: [:id, :name, :category_id]
          }
        }
      )
    end

    def create_leaf(link, link_name)
      leaf = @tree.leaf_link(link, link_name)

      if leaf.present?
        category_name = Category.find(link.category_id)[:name]

        msg = {
            data: {
                title: 'Tree Update',
                body: "Leaf '#{link_name}' added to '#{category_name}' on your tree"
            }
        }
        notify_user msg

        msg = {
            data: {
                title: "Follow Branch - leaf added",
                body: "leaf '#{leaf.name}' was just added to branch '#{leaf.branch.category.name}'"
            }
        }
        leaf.branch.notify_followers msg
      end
    end
end
