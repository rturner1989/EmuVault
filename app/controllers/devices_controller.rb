class DevicesController < ApplicationController
  before_action :set_device, only: %i[show edit update destroy]

  def index
    authorize! Device
    @devices = DeviceDecorator.decorate(Device.order(:name))
  end

  def show
    authorize! @device
    @device = DeviceDecorator.new(@device)
  end

  def new
    authorize! Device, to: :new?
    @form = DeviceForm.new
  end

  def create
    authorize! Device, to: :create?
    @form = DeviceForm.new(device_params)
    device = Device.new
    if @form.persist(device)
      redirect_to device, notice: "Device added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize! @device
    @form = DeviceForm.from(@device)
  end

  def update
    authorize! @device
    @form = DeviceForm.new(device_params)
    @form.id = @device.id
    if @form.persist(@device)
      redirect_to @device, notice: "Device updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! @device
    @device.destroy
    redirect_to devices_path, notice: "Device removed.", status: :see_other
  end

  private

  def set_device
    @device = Device.find(params[:id])
  end

  def device_params
    params.require(:device).permit(:name, :device_type, :identifier)
  end
end
