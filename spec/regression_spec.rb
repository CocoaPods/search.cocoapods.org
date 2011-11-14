# coding: utf-8
#
describe 'MacRuby Regression Spec' do

  it 'does not raise when autoloading a constant' do
    expect do
      Xcodeproj::Config # With cocoapods-0.3.0 this crashed.
    end.not_to raise_error
  end

end