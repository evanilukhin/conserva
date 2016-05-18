require File.expand_path '../spec_helper.rb', __FILE__
class APITest < Minitest::Test
  include Rack::Test::Methods

  def app
    ConvertServiceApi
  end

  def test_exist_task_state
    get '/api/v1/task/1'
    response = JSON.parse(last_response.body)
    assert_equal 1,response['id']
    assert last_response.ok?
  end

  def test_not_exist_task_state
    get '/api/v1/task/666'
    assert_equal 404, last_response.status
  end
  def test_get_file
    get '/api/v1/task/1'
    assert last_response.ok?
  end
  def test_send_file
    post '/api/v1/task',
                    input_extension: 'jpg',
                    output_extension: 'png',
                    file: Rack::Test::UploadedFile.new("#{ENV['file_storage']}/1.jpg", 'image/jpg')
    assert_equal 201, last_response.status
  end

end
