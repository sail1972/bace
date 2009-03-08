class RolesController < ApplicationController
  def index
    @roles = Role.paginate(:page => params[:page]||1)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @roles }
    end
  end

  def show
    @role = Role.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @role }
    end
  end

  def new
    @role = Role.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @role }
    end
  end

  def edit
    @role = Role.find(params[:id])
  end

  
  def create
    @role = Role.new(params[:role])
    respond_to do |format|
      if @role.save
        @role.move_to_child_of(params[:role][:parent_id]) if params[:role][:parent_id].present?
        flash[:notice] = 'Role was successfully created.'
        format.html { redirect_to(@role) }
        format.xml  { render :xml => @role, :status => :created, :location => @role }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @role = Role.find(params[:id])
    respond_to do |format|
      if @role.update_attributes(params[:role])
        @role.move_to_child_of(params[:role][:parent_id]) if params[:role][:parent_id].present?
        flash[:notice] = 'Role was successfully updated.'
        format.html { redirect_to(@role) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(roles_url) }
      format.xml  { head :ok }
    end
  end

  def edit_permissions
    @role = Role.find(params[:id], :include => :permissions_roles)
    @permissions = Permission.all(:order => 'lft')
  end
      
  def change_permissions
    @role = Role.find(params[:id])
    permissions_roles = []
    params[:permissions].each do |k, v|
      next if v == 'inherit'
      permissions_role = @role.permissions_roles.find_or_initialize_by_permission_id(k)
      permissions_role.granted = v
      permissions_roles <<  permissions_role
    end if params[:permissions].present?
    respond_to do |format|
      if @role.permissions_roles.replace permissions_roles
        flash[:notice] = 'Role was successfully updated.'
        format.html { redirect_to(@role) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

end
