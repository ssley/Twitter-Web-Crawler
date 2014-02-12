class ActressesController < ApplicationController
  def new
    @actress = Actress.new
  end
end
