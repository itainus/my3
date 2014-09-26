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
    Rails.logger.info "[DEBUG INFO] ############## TreeController - create_new_link - link_name = #{link_name}, link_url = #{link_url}, link_category_id = #{link_category_id} ##############"

    link = Link.create_if_not_exists(link_url, link_category_id)

    @tree.leaf_link(link, link_name)

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
      # @tree.destroy_leaf(leaf_id)
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
      link = Link.create_if_not_exists(link_url, link_category_id)
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

    def render_tree
      render json: @tree.as_json(
        only: [:id, :name],
        include: {
          branches: {
            only: [:id],
            include: {
                category: {
                    only: [:id, :name, :category_id]
                },
                leafs: {
                    only: [:id, :name],
                    include: {
                        link: {
                            only: [:id, :name, :url, :category_id]
                        }
                    }
                }
            },
          }
      })
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

    # def render_leafs
    #   render json: @tree.leafs.as_json(
    #     only: [:id, :name],
    #     include: {
    #       link: {
    #         only: [:id, :url, :category_id]
    #       }
    #     }
    #   )
    # end

end
