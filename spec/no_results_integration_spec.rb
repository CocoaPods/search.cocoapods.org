# coding: utf-8
#
require File.expand_path '../spec_helper', __FILE__
require 'picky-client/spec'

# Uses the fixed set of pods from the ./data directory.
#
describe 'Integration Tests' do

  def no_results
    @no_results ||= Picky::TestClient.new CocoapodSearch, path: '/no_results.json'
  end

  it 'defends against overlong queries' do
    Yajl.load(no_results.send_search(query: 'Autolayout%20Tips:%20%20For%20AutoLayout%20to%20be%20correct,%20make%20sure%20you%20complete%20the%20following:%20%20For%20height%20to%20calculate%20correctly,%20set%20hugging/compression%20priorites%20for%20all%20labels.%20This%20is%20one%20of%20the%20most%20important%20aspects%20of%20having%20the%20cell%20size%20itself.%20setContentCompressionResistancePriority%20needs%20to%20be%20set%20for%20all%20labels%20to%20UILayoutPriorityRequired%20on%20the%20Vertical%20axis.%20This%20prevents%20the%20label%20from%20shrinking%20to%20satisfy%20constraints%20and%20will%20not%20cut%20off%20any%20text.%20i.e.%20[self.label%20setContentCompressionResistancePriority:UILayoutPriorityRequired%20forAxis:UILayoutConstraintAxisVertical];%20%20Set%20PreferredMaxLayoutWidth%20for%20all%20labels%20that%20will%20have%20a%20auto%20height.%20This%20should%20equal%20width%20of%20cell%20minus%20any%20buffers%20on%20sides.%20i.e%20self.label.preferredMaxLayoutWidth%20=%20defaultSize%20-%20buffers;%20%20Set%20any%20imageView%27s%20images%20correctly%20so%20they%20have%20proper%20size.%20Remember%20if%20you%20don%27t%20set%20a%20fixed%20width/height%20on%20a%20UIImageView%20it%20will%20use%20the%201x%20intrinsic%20size%20of%20the%20image%20to%20calculate%20a%20constraint.%20So%20if%20your%20image%20isn%27t%20sized%20correctly%20it%20will%20produce%20an%20incorrect%20value.'))['split'].should == [["layout"], 16]
  end
  it 'will return the right tag facets' do
    Yajl.load(no_results.send_search)['tag'].keys.sort.should == ["alert", "analytics", "api", "button", "client", "communication", "controller", "http", "image", "json", "kit", "layout", "logging", "navigation", "network", "notification", "parser", "progress", "rest", "table", "test", "text", "view", "xml"]
  end
  it 'will return a correctly split query' do
    Yajl.load(no_results.send_search(query: 'meow'))['split'].should == [[], 0]
  end
  it 'will return a correctly split query' do
    Yajl.load(no_results.send_search(query: 'afnetworking'))['split'].should == [["networking"], 5]
  end

end
