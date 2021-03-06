RSpec.describe 'PUT edited article ' do
  describe 'Journalist can edit article successfully' do 
    let(:journalist) { create(:user, role: 'journalist') }
    let(:credentials) { journalist.create_new_auth_token }
    let(:headers) {{ HTTP_ACCEPT: "application/json" }.merge!(credentials) }
    let(:article) { create(:article, journalist: journalist) }

    before do
      put "/api/v1/articles/#{article.id}", 
      params: {
        title: 'New apple-stuff on the way',
        content: 'This is changed',
        author: 'Author',
        image: {
          type: 'application/jpg',
          encoder: 'name=new_iphone.jpg;base64',
          data: 'iVBORw0KGgoAAAANSUhEUgAABjAAAAOmCAYAAABFYNwHAAAgAElEQVR4XuzdB3gU1cLG8Te9EEgISQi9I71KFbBXbFixN6zfvSiIjSuKInoVFOyIDcWuiKiIol4Q6SBVOtI7IYSWBkm',
          extension: 'jpg'
        }
      },
      headers: headers
    end

    it 'journalist changes content of article' do
      expect(response.status).to eq 200
    end

    it 'article is changed' do
      article = Article.find_by(title: response.request.params['title'])
      expect(article.content).to eq("This is changed")
    end

    it 'should have an attached image' do
      article = Article.find_by(title: response.request.params['title'])
      expect(article.image.attached?).to eq true
    end
  end

  describe 'Subscriber can not edit article' do 
    let(:just_a_user) { create(:user, role: 'subscriber') }
    let(:credentials) { just_a_user.create_new_auth_token}
    let(:headers) {{ HTTP_ACCEPT: "application/json" }.merge!(credentials)}
    let(:article) { create(:article) }

    before do
      put "/api/v1/articles/#{article.id}", 
      params: {
        title: 'New apple-stuff on the way',
        content: 'This is changed',
        author: 'Author',
        image: {
          type: 'application/jpg',
          encoder: 'name=new_iphone.jpg;base64',
          data: 'iVBORw0KGgoAAAANSUhEUgAABjAAAAOmCAYAAABFYNwHAAAgAElEQVR4XuzdB3gU1cLG8Te9EEgISQi9I71KFbBXbFixN6zfvSiIjSuKInoVFOyIDcWuiKiIol4Q6SBVOtI7IYSWBkm',
          extension: 'jpg'
        }
      },
      headers: headers
    end

    it 'gives error status' do
      expect(response.status).to eq 401
    end

    it 'gives error message' do
      expect(response_json['error']).to eq "You are not authorized!"
    end
  end
end