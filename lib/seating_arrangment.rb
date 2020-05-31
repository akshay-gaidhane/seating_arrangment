require 'json'
require 'byebug'
class SeatingArrangment
  attr_accessor :input_json, :request_seats

  def initialize(input_json, request_seats)
    @venue_available_seats = JSON.parse(input_json)
    @request_seats = request_seats
  end
  def available_seats
    # Retrived row and column
    rows = @venue_available_seats["venue"]["layout"]["rows"]
    columns = @venue_available_seats["venue"]["layout"]["columns"]
    # Create hash of row and column
    arrangment_hash = []
    alphabet_array = 'a'.upto('z').to_a
    rows.times do |r|
      r_a = {}
      alph = alphabet_array[r]
      columns.times do |cl|
        r_a[alph+(cl + 1).to_s] = "A"
      end
      arrangment_hash << r_a
    end
    # updated seat's status from input json 
    @venue_available_seats["seats"].keys.each do |l|
      key = @venue_available_seats["seats"].select {|n| n[l]}
      arrangment_hash.select{|m| m[l] }.first[l] = key[l]["status"]
    end if @venue_available_seats["seats"].keys.any?
    @result = []
    @result << find_best_seats(arrangment_hash, columns)
    @result.compact
  end
  # To find best seats from row and from center position.
  def find_best_seats(arrangment_hash, columns)
    center_seat = columns/2
    alloted_seat = nil
    arrangment_hash.each do |l|
      row = l.keys.first.split("", 2)
      @request_seats.times do |m|
        # If row has eeven single unavailable seat
        if l.values.include? ("U")
          # Loop trough seats
          loop_through_center(l, center_seat)
          break if @request_seats == 0 
        else
          # If all the seats in row is available then allot center seat
          l[row.first + center_seat.to_s] = "U"
          @request_seats -= 1
          @result << "Alloted seat is #{row.first + center_seat.to_s}"
          break if @request_seats == 0 
        end
      end
    end
    puts arrangment_hash
  end
  # Allotement of seats from center
  def loop_through_center(r, center_seat)
    add = 0
    delete = 0
    row_alphabet = r.keys.first.split("", 2)[0]
    r.length.times.each do |l|
      if l%2 == 0
        add = add + 1
        if r[row_alphabet+(center_seat + add ).to_s] == "A"
          r[row_alphabet+(center_seat + add ).to_s] = "U"
          @result << "Alloted seat is #{row_alphabet+(center_seat + add ).to_s}"
          @request_seats -= 1
          break if @request_seats == 0 
        end
      else
        delete = delete - 1
        if r[row_alphabet+(center_seat + delete ).to_s] == "A"
          r[row_alphabet+(center_seat + delete ).to_s] = "U"
          @result << "Alloted seat is #{row_alphabet+(center_seat + delete ).to_s}"
          @request_seats -= 1
          break if @request_seats == 0 
        end
      end
    end
  end
end