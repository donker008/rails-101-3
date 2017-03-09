class GroupsController < ApplicationController
  before_action :authenticate_user! , only: [:new, :create, :update, :destroy, :edit]
  before_action :check_user_permission , only: [:update, :destroy, :edit]

  def index
    @groups = Group.all
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    @group.user = current_user
    if @group.save
      redirect_to groups_path
    else
      render :new
    end

  end

  def show
    @group = Group.find(params[:id])
    @posts = @group.posts.recent.paginate(:page => params[:page], :per_page => 5)
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    if @group.update(group_params)
      redirect_to groups_path, notice: "update Success"
    else
      render :edit
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    flash[:alert] = "删除群组成功"
    redirect_to groups_path
  end

  def join
    @group = Group.find(params[:id])
    if !current_user.is_member_of?(@group)
      current_user.join!(@group)
      flash[:notice] = "Join group success!"
    else
      flash[:notice] = "You already joined!"
    end
    redirect_to group_path(@group)
  end

  def quit
    @group = Group.find(params[:id])
    if current_user.is_member_of?(@group)
      current_user.quit!(@group)
      flash[:alert] = "quit group success!"
    else
       flash[:alert] = "You not the member of group, how you can quit!"
    end
      redirect_to group_path(@group)
  end

 private
 def group_params
   params.require(:group).permit(:title,:description)
 end

 def check_user_permission
   @group = Group.find(params[:id])
   if !current_user || current_user != @group.user
     redirect_to root_path, alert: "You have no permission."
   end
 end
end
