class TransactionsController < ApplicationController

    before_action :redirect_to_404_if_not_authorized

    TRANSACTIONS_PER_PAGE = 20 # This will be used for pagination, max number of transactionsin each page is 20

    def index
        @page = params.fetch(:page, 0).to_i

        # Check wehther the user is accessing the transactions for a specific account or for all accounts a user has
        if(params.has_key?(:account_id))
            # Get transactions for a specific account
            account = Account.find(params[:account_id])
            transactions_sent = account.sent_transactions
            transactions_received = account.received_transactions
        else
            # Get transactions for all accounts the user has
            transactions_sent = current_user.sent_transactions
            transactions_received = current_user.received_transactions
        end
        
        @transactions_all = (transactions_sent + transactions_received).sort_by &:created_at # Sort the transactions
        paginate # Paginate the page
        @transactions_all = @transactions_all[@page * TRANSACTIONS_PER_PAGE, TRANSACTIONS_PER_PAGE] # Set the variable to contain all transactions in the current page
        
    end

    private
        # Function redirects user to 404 if they are not logged in or authorized to view that account
        def redirect_to_404_if_not_authorized
            redirect_to_login_if_not_logged_in

            # If the user calls the index for their account, it's a GET request identifying the user by the session, hence not no need for further authentication
            unless(params.has_key?(:account_id))
                return
            end

            # Authentication for transactions for a specific account, authentication needs to be done
            unless(params.has_key?(:account_id) && Account.exists?(params[:account_id]) && Account.find(params[:account_id]).user_id == current_user.id)
                render file: "#{Rails.root}/public/404.html", layout: false, status: 404 # Render 404 page
            end
        end

        # Function that paginates the transactions into different pages
        def paginate
            @max_pages = (@transactions_all.size/TRANSACTIONS_PER_PAGE)
            if(@max_pages == 0)
                @max_pages = 1 # Because @max_pages indexes from 0, if its 0 change it to 1
            end

            # Boundary conditions for pages, a user should not be able to paginate under 0 or over the max limit
            if(@page >= @max_pages || @page < 0) 
                redirect_to transactions_path
            end
        end
    
end
