# frozen_string_literal: true
# Simple helper class.
#
class Platform
  ON_IOS = /(on|platform):ios/i
  ON_OSX = /(on|platform):osx/i

  # Extracts the platform symbol from the query.
  #
  # TODO: There is probably a query parser of Picky that could be used here.
  #
  def self.extract_from(text)
    ios = text =~ ON_IOS
    osx = text =~ ON_OSX

    if ios && osx
      :both
    elsif ios
      :ios
    elsif osx
      :osx
    else
      :either
    end
  end
end
