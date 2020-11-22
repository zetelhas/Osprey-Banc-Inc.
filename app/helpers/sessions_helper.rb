module SessionsHelper

    # Log the user in and assign the session user_id to the user's ID
    def login(user)
        session[:user_id] = user.id
    end

    # Find the current user
    def current_user
        if session[:user_id]
            User.find_by(id: session[:user_id])
        end
    end

    # Checks if user is logged in
    def logged_in?
        !current_user.nil?
    end

    # Logs the user out by terminating the session
    def logout
        session.delete(:user_id)
    end
end