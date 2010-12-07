# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_LinearEquations_session',
  :secret      => '890d88a3a4da5f6b6aa0c5ea6b1d6c7d38a03bdf8bba5bfcedc844bb64f11dc1ddb6a903446ec28183fe4c9a16e6480c8c0ec35b04254cc3bbe773d2e802c88b'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
