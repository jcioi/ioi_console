class Service::SpecialRequirementNotesController < Service::ApplicationController
  def edit
  end

  def update
    current_user.update!(person_params)
    redirect_to '/', notice: 'Your special need information has been updated.'
  end

  private

  def person_params
    params.require(:person).permit(:special_requirement_note)
  end
end
