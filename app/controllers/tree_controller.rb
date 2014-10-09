class TreeController < ApplicationController

  before_filter :init

  def init
    Rails.logger.info "[DEBUG INFO] ############## TreeController - init ##############"

    trees = current_user.trees.where(:id => params[:id])

    if trees.blank?
      e = {
          error: "tree #{params[:id]} is not owned by user #{current_user.id}"
      }
      render json: e.as_json
    end

    @tree = trees.first
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

    if category_name.blank? or category_parent_id.blank?
      Rails.logger.info "[DEBUG INFO] blank param"
      return render_tree
    end

    category = Category.create_if_not_exists(category_name, category_parent_id)

    @tree.branch_category(category.id)

    render_tree
  end

  def add_category
    category_id = params[:category_id]
    Rails.logger.info "[DEBUG INFO] ############## TreeController - add_category - category_id = #{category_id} ##############"

    @tree.branch_category(category_id)

    render_tree
  end

  def remove_category
    branch_id = params[:branch_id]
    Rails.logger.info "[DEBUG INFO] ############## TreeController - remove_category - branch_id = #{branch_id} ##############"

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

    link_meta_data = {
        :favicon => link_img
    }

    link = Link.create_if_not_exists(link_url, link_category_id, link_meta_data)


    # linkImg = Base64.encode64(open(link_img){ |io| io.read })
    # src="data:image/png;base64,AAABA...."
    
    leaf = @tree.leaf_link(link, link_name)

    Rails.logger.info "[DEBUG INFO] leaf = #{leaf.blank?}"

    if leaf.present?
      category_name = Category.find(link_category_id)[:name]

      msg = {
          data: {
              title: 'Tree Update',
              body: "Leaf '#{link_name}' added to '#{category_name}' on your tree"
          }
      }

      notify_tree msg
    end

    render_tree
  end

  def add_link
    link_id = params[:link_id]
    link_name = params[:link_name]
    Rails.logger.info "[DEBUG INFO] ############## TreeController - add_link - link_id = #{link_id}, - link_name = #{link_name} ##############"

    if Link.exists?(link_id)
      link = Link.find(link_id)
      @tree.leaf_link(link, link_name)
    else
      Rails.logger.info "[DEBUG INFO] link '#{link_id}' dose not exists"
    end

    render_tree
  end

  def remove_link
    leaf_id = params[:leaf_id]
    Rails.logger.info "[DEBUG INFO] ############## TreeController - remove_link - leaf_id = #{leaf_id} ##############"

    if @tree.leaf_exists(leaf_id)
      Leaf.destroy(leaf_id)
    else
      Rails.logger.info "[DEBUG INFO] leaf '#{leaf_id}' dose not exists"
    end

    render_tree
  end

  def update_link
    leaf_id = params[:leaf_id]
    link_name = params[:link_name]
    link_url = params[:link_url]
    link_category_id = params[:link_category_id]
    Rails.logger.info "[DEBUG INFO] ############## TreeController - update_link - leaf_id = #{leaf_id} - new link_name = #{link_name}, new link_url = #{link_url}, new link_category_id = #{link_category_id}##############"

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


    if (cats.first)
      category = Category.find(cats.first.first)
      Rails.logger.info "[DEBUG INFO] ############## TreeController - suggest_branch - done - category_id = #{category.id} - name = #{category.name}"
      render json: category
    else
      Rails.logger.info "[DEBUG INFO] ############## TreeController - suggest_branch - done - no suggest"
      render json: {}
    end
  end

  private

    def notify_tree(msg)
      # WebsocketRails[:tree].trigger 'update', msg
      WebsocketRails.users[current_user.id].send_message :update, msg, :namespace => :tree
    end

    def render_tree
      render json: @trees.as_json
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
end
