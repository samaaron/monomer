require File.dirname(__FILE__) + '/../../../spec_helper'


describe Monomer::Listener do
  before(:each) do
  
    @block_a = lambda {:a}
    @block_b = lambda {:b}
    @block_c = lambda {:c}
    
    class A < Monomer::Listener
      loop_on_button_sustain(&@block_a)
    end
    
    class B < Monomer::Listener
      on_start(&@block_b)
    end
    
    class C < Monomer::Listener
      before_start(&@block_c)
    end
  end
  
  it "should have defined each of the classes with the appropriate superclass" do
    A.superclass.should == Monomer::Listener
    B.superclass.should == Monomer::Listener
    C.superclass.should == Monomer::Listener
  end
  
  it "should have defined loop_on_button_sustain on A's metaclass" do
   # A.metaclass.instance_methods.grep(/loop_on_button_sustain/).should_not == nil
  end
  
  it "should not have defined loop_on_button_sustain on either A or B's metaclass" do
   # B.metaclass.instance_methods.grep(/loop_on_button_sustain/).should == nil
   # C.metaclass.instance_methods.grep(/loop_on_button_sustain/).should == nil
  end
  
  it "should have made the correct blocks available to the metaclasses of the classes" do
    A.loop_on_button_sustain.should == @block_a
    B.on_start.should == @block_b 
    C.before_start.should == @block_c
  end
  
  it "should have deifined key sustain on and key sustain off for instances of class A, but not others" do
    A.new.respond_to?(:button_sustain_on).should  == true
    A.new.respond_to?(:button_sustain_off).should == true
    B.new.respond_to?(:button_sustain_on).should  == false
    B.new.respond_to?(:button_sustain_off).should == false
    C.new.respond_to?(:button_sustain_on).should  == false
    C.new.respond_to?(:button_sustain_off).should == false
  end
end