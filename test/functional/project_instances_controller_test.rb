require 'test_helper'

class ProjectInstancesControllerTest < ActionController::TestCase
  fixtures :question_instances, :answer_instances, :projects

  setup do
    @project_instance = ProjectInstance.find(project_instances(:one).id)
  end

  # Prueba que sin realizar autenticación esten accesibles las partes publicas
  # y no accesibles las privadas
  test 'public and private actions' do
    id_param = {id: @project_instance.to_param}
    identifier_project = {identifier: projects(:manual).to_param}
    id_project = {id: projects(:manual).to_param}
    public_actions = [
      [:post, :create],
      [:get, :new, identifier_project]
    ]
    private_actions = [
      [:get, :index, id_project],
      [:get, :show, id_param],
      [:get, :edit, id_param],
      [:put, :update, id_param],
      [:delete, :destroy, id_param]
    ]

    private_actions.each do |action|
      send *action
      assert_redirected_to login_users_path
      assert_equal I18n.t(:'messages.must_be_authenticated'), flash[:notice]
    end

    public_actions.each do |action|
      send *action
      assert_response :success
    end
  end

  test 'list project instances' do
    perform_auth
    get :index
    assert_response :success
    assert_not_nil assigns(:project_instances)
    assert_select '#error_body', false
    assert_template 'project_instances/index'
  end

  test 'show project instance' do
    perform_auth
    get :show, id: @project_instance.to_param
    assert_response :success
    assert_not_nil assigns(:project_instance)
    assert_select '#error_body', false
    assert_template 'project_instances/show'
  end

  test 'new project instance' do
    get :new, identifier: @project_instance.to_param
    assert_response :success
    assert_not_nil assigns(:project_instance)
    assert_template 'project_instances/new'
  end

  test 'create project instance' do
    perform_auth
    @request.host = 'admin.cocts.com'
    question = projects(:manual).questions.first
    answers = question.answers

    assert_difference 'ProjectInstance.count' do
      post :create, {
        project_instance: {
          first_name: 'Firstname',
          professor_name: 'Professorname',
          email: 'test@cirope.com.ar',
          age: 25,
          degree: 'doctor',
          genre: 'male',
          student_status: 'no_study',
          teacher_status: 'in_training',
          teacher_level: 'primary',
          country: 'Argentina',
          educational_center_name: 'UNCuyo',
          project_type: 0,
          educational_center_city: 'Mza',
          study_subjects_different: 2,
          project_id: projects(:manual).id,
          question_instances_attributes: [
            {
              question_id: question.id,
              question_text: question.question,
              code: question.code,
              dimension: question.dimension,
              answer_instances_attributes: [
                {
                  answer_id: answers.first.id,
                  valuation: '1',
                  order: answers.first.order,
                  answer_text: answers.first.answer,
                  answer_category: answers.first.category
                },
                {
                  answer_id: answers.last.id,
                  valuation: '3',
                  order: answers.last.order,
                  answer_text: answers.last.answer,
                  answer_category: answers.last.category
                }
              ]
            }
          ]
        }
      }
    end

    assert_redirected_to projects_path
    assert_not_nil assigns(:project_instance)
    assert_equal 'Firstname', assigns(:project_instance).first_name
  end


  test 'edit project instance' do
    perform_auth
    get :edit, id: @project_instance.to_param
    assert_response :success
    assert_not_nil assigns(:project_instance)
    assert_template 'project_instances/edit'
  end

  test 'update project instance' do
    perform_auth

    question = @project_instance.project.questions.first
    answers = question.answers

    assert_no_difference ['ProjectInstance.count', 'QuestionInstance.count'] do
      put :update, {
        id: @project_instance.to_param,
        project_instance: {
          first_name: 'Updated firstname',
          professor_name: 'Updated professorname',
          email: 'updated@cirope.com.ar',
        }
      }
    end

    assert_redirected_to project_instance_path
    assert_not_nil assigns(:project_instance)
    assert_equal 'Updated firstname', assigns(:project_instance).first_name
    assert_equal 'updated@cirope.com.ar', assigns(:project_instance).email

  end

  test 'destroy project instance' do
    perform_auth
    id_project = @project_instance.project_id
    assert_difference('ProjectInstance.count', -1) do
      delete :destroy, id: @project_instance.to_param
    end

    assert_redirected_to project_instances_url
  end

  test 'show project instance in pdf' do
    perform_auth
    get :show, id: @project_instance.to_param, format: 'pdf'
    assert_redirected_to "/#{@project_instance.pdf_relative_path}"
    assert_not_nil assigns(:project_instance)
    assert_select '#error_body', false
  end
end
