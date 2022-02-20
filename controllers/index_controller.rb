# frozen_string_literal: true

class IndexController < ApplicationController
  def view
    current_user
  end
end
