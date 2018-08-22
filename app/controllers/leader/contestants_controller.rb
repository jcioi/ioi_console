class Leader::ContestantsController < Leader::ApplicationController
  before_action :set_person, only: [:edit, :update]

  def index
    @people = Person.all.joins(:team).where(team: current_user.team, role: :contestant).order(login: :asc)
  end

  # GET /people/1/edit
  def edit
  end

  # PATCH/PUT /people/1
  # PATCH/PUT /people/1.json
  def update
    respond_to do |format|
      if @person.update(person_params)
        format.html { redirect_to contestants_path, notice: 'Contestant was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  private
    def set_person
      @person = Person.find(params[:id])
      return render(status: 404, text: ':)') unless @person.contestant?
    end

    def person_params
      params.require(:person).permit(:special_requirement_note)
    end
end
