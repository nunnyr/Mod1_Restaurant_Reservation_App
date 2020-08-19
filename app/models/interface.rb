class Interface
    attr_reader :prompt
    attr_accessor :user

    def initialize
        @prompt = TTY::Prompt.new
    end

    def welcome
        # self -> instance of the Interface
        # choice = prompt.select("Welcome to our Application. What would you like to do?", ["See All Plants", "See All Categories", "Create A User"])
        # if choice == "See All Plants" 
        # elsif choice == "See All Categories"
        # end

        prompt.select("Please make a selection:") do |menu|
            menu.choice "Log In", -> { log_returning_user_helper }
            menu.choice "Create a User", -> { create_user_helper }
        end

    end

    #this should ask for the user's name + password to find them in the User table of our database
    #once found, will bring them to the main menu
    def log_returning_user_helper
        user_log_in_info = User.log_in()
        self.user = user_log_in_info
        puts "Thanks for coming back #{self.user.name}!"
        self.main_menu
    end

    #this will create a user (make a user instance) by getting info from them
    #until they create a user name that is not taken, the .register method in the User class will continue
    #once they successfully create a user, will be guided towards the main menu
    def create_user_helper
       user_register_return_value = User.register()
       until user_register_return_value
        user_register_return_value = User.register()
       end
       puts "Successfully Created!"
       self.user = user_register_return_value #the user associated with the user instance just created (attr_accessor :user -> should we rename?)
       self.main_menu
    end


    def main_menu
        user.reload #makes sure that we get the most up to date info
        system "clear" #pushes this to the top of the terminal
        puts "Welcome to our app!" #our app will change to our app name when we come up with it
        prompt.select("What would you like to do?") do |menu|
            menu.choice "See my Reservations", -> {display_user_reservations_helper}
            menu.choice "Make a Reservation", -> { display_and_add_reservations_helper }
        end
    end

    #displays all of the user's reservations
    #user chooses one of their reservations
    #Need help with making the user's reservations a choice so that they can either update or delete - Wave did with Sylwia!
    def display_user_reservations_helper
        # self.user <- User who is logged in
        # self.user.restaurants <- All of the restaurants associated with the User
        # self.user.reservations <- All of the reservation instances
        # refer to Eric's video around 1:22:55 for more info on getting specific info out of objects! 
        all_choices = []
        self.user.reservations.each do |user_reservation|
            all_choices << "#{user_reservation.date} - #{user_reservation.restaurant.name}"
        end
        choice = prompt.select("What reservation do you want to see?", all_choices)
        see_chosen_reservation(choice)

        # sleep 5 #after 5 seconds of inactivity
        # self.main_menu #goes back to main menu
        # # self.main_menu <- To take me back to the main_menu
    end

    #displays the chosen reservation
    #asks if the user want to update or cancel the chosen reservation
    #do we want to display the chosen restaurant's more info again? - YES Stretch Goal
    def see_chosen_reservation(chosen_reservation_instance)
        puts "You have a reservation at #{chosen_reservation_instance.restaurant.name} on #{chosen_reservation_instance.date}"
        
        #Sylwia's way
        all_choices = ["update", "cancel", "back"]
        choice = prompt.select("What do you want do?", all_choices)
        if choice == "update"
          update_reservation(chosen_reservation_instance)
        elsif choice == "cancel"
          delete_reservation(chosen_reservation_instance)
        elsif choice == "back"
            self.main_menu
        end

        # #Eric's way - I'm pretty sure this is the same
        # prompt.select("What would you like to do?") do |menu|
        #     menu.choice "update", -> {update_reservation(chosen_reservation_instance)}
        #     menu.choice "cancel", -> { delete_reservation(chosen_reservation_instance) }
        #     menu.choice "back", -> {self.main_menu}
        # end
    end

     #updates the chosen reservation
     #can choose to update the date and/or the party_size
     def update_reservation(chosen_reservation_instance)
        #code for updating
        prompt.select("What would you like to update?") do |menu|
            menu.choice "date", -> {choose_new_date(chosen_reservation_instance)}
            menu.choice "party size", -> {chosen_reservation_instance.party_size }
            menu.choice "back", -> {self.main_menu}
        end
        puts "updated!"
    end

    #updates the reservation date/time
    def choose_new_date(chosen_reservation_instance)
        new_date = TTY::Prompt.new.ask("Which date? Please note that you can only change this once")
        #How can we restrict a user from only updating something ONE time?
        chosen_reservation_instance.update(date: new_date)
        puts "New date confirmed!"
        self.main_menu
    end

    def choose_new_party(chosen_reservation_instance)
        new_party = TTY::Prompt.new.ask("How many for dinner? Please note that you can only change this once")
        chosen_reservation_instance.update(party_size: new_party)
        puts "New party size confirmed!"
        self.main_menu
    end

    #deletes the chosen reservation
    def delete_reservation(chosen_reservation_instance)
        #code for deleting
        puts
        prompt.yes?("Do you want to cancel this reservation?")
        puts "cancelled"
    end

    #displays all of the restaurants
    #creates a new reservation
    #Note: I think that this can be refractored, perhaps can look at above to see where/how - Wave
    def display_and_add_reservations_helper
        # Restaurant.all_names is defined in the Restaurant class and shows all restaurants => [{name => id}, {name => id}]
        chosen_restaurant_id = prompt.select("View all of our participating restaurants", Restaurant.all_names)

        #Need to display the "more information" about the chosen restaurant

        #after seeing more information about a restaurant, ask if user wants to make a reservation
        #if yes, create a new reservation
        #if no, bring back to see all restaurants or go to main menu
        if prompt.yes?("Do you want to make a reservation?")
            reservation_date = TTY::Prompt.new.ask("What date and time would you like to dine?") #haha I rhymed
            reservation_party_size = TTY::Prompt.new.ask("How many people?")
            new_reservation = Reservation.create(guest_id: self.user.id, restaurant_id: chosen_restaurant_id, date: reservation_date, party_size: reservation_party_size)
        else
            prompt.select("What would you like to do?") do |menu|
                menu.choice "Go back to all restaurants", -> {display_and_add_reservations_helper}
                menu.choice "Go back to main menu", -> { self.main_menu }
            end
        end
    end

end