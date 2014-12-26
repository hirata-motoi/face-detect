require 'opencv'
include OpenCV

module Twitter
  class API < Grape::API
    # versionは:headerや、:paramなどもあり
    version 'v1', using: :path, vendor: 'twitter'
    format :json

    helpers do
      def current_user
        @current_user ||= User.authorize!(env)
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
    end

    resource :face_detect do
      desc "aaaaaaaa"
      get :test do
        { hello: "world" }
      end

      desc "Image File"
      params do
        requires :file, type: String, desc: "Image File."
      end
      route_param :file do
          get do
            # 画像を編集
            image_path = "/home/hirata.motoi/Metro/static/image/face_detect/" + params[:file] + ".jpg"
            puts image_path
            image = IplImage.load image_path, 1

            image_frame = IplImage.load '/home/hirata.motoi/Metro/static/image/frame.png', 1
            #detector = CvHaarClassifierCascade::load './haarcascade_frontalface_alt.xml'
            detector = CvHaarClassifierCascade::load '/usr/local/share/OpenCV/haarcascades/haarcascade_frontalface_alt2.xml'

            detector.detect_objects(image).each do |rect|
              image.rectangle! rect.top_left, rect.bottom_right, :color => OpenCV::CvColor::Red
            end

            image.save_image(image_path);
            { path: image_path }
          end
      end
    end

    resource :statuses do
      desc "Return a public timeline."
      get :public_timeline do
        Status.limit(20)
      end

      desc "Return a personal timeline."
      get :home_timeline do
        authenticate!
        current_user.statuses.limit(20)
      end

      desc "Return a status."
      params do
        requires :id, type: Integer, desc: "Status id."
      end
      route_param :id do
        get do
          Status.find(params[:id])
        end
      end

      desc "Create a status."
      params do
        requires :status, type: String, desc: "Your status."
      end
      post do
        authenticate!
        Status.create!({
          user: current_user,
          text: params[:status]
        })
      end

      desc "Update a status."
      params do
        requires :id, type: String, desc: "Status ID."
        requires :status, type: String, desc: "Your status."
      end
      put ':id' do
        authenticate!
        current_user.statuses.find(params[:id]).update({
          user: current_user,
          text: params[:status]
        })
      end

      desc "Delete a status."
      params do
        requires :id, type: String, desc: "Status ID."
      end
      delete ':id' do
        authenticate!
        current_user.statuses.find(params[:id]).destroy
      end
    end
  end
end

