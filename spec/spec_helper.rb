require 'rspec'
require File.expand_path("../../lib/hash_verifier", __FILE__)

describe HashVerifier do
  it "Should match empty hash to empty pattern" do
    HashVerifier.verify({}, {}).should eql true
    HashVerifier.strict_verify({}, {}).should eql true
  end

  it "Should not match different size hashes in strict mode" do
    HashVerifier.verify({a: 1}, {}, false).should eql true
    expect {
      HashVerifier.strict_verify({a: 1}, {}).should eql true
    }.to raise_error(SizeMismatch)
    expect {
      HashVerifier.strict_verify({a: 1, b: 2}, {b: Fixnum}).should eql true
    }.to raise_error(SizeMismatch)
  end

  it "should match classes loosely in regular mode" do
    HashVerifier.verify({a: 1}, {a: Fixnum}).should eql true
    HashVerifier.verify({a: 1}, {a: Numeric}).should eql true
    expect {
      HashVerifier.verify({a: 1}, {a: String}).should eql true
    }.to raise_error(ClassMismatch)
  end

  it "should matc classes strictly in strict mode" do
    HashVerifier.strict_verify({a: 1}, {a: Fixnum}).should eql true
    expect {
      HashVerifier.strict_verify({a: 1}, {a: Numeric})
    }.to raise_error(ClassMismatch)
  end

  it "should match values in pattern" do
    HashVerifier.verify({a: 1, b: "Sup"}, {a: 1, b: "Sup"}).should eql true
    HashVerifier.verify({a: 1, b: "Sup", c: "something extra"}, {a: 1}).should eql true

    HashVerifier.strict_verify({a: 1, b: "Sup"}, {a: 1, b: "Sup"}).should eql true
    expect {
      HashVerifier.strict_verify({a: 2}, {a: 1})
    }.to raise_error(ValueMismatch)
  end

  it "should match combination of matchers" do
    HashVerifier.verify({a: 1, b: "Sup"}, {a: 1, b: String}).should eql true
    HashVerifier.verify({a: 1, b: "Sup"}, {a: Integer, b: String}).should eql true
    HashVerifier.verify({a: 1, b: "Sup"}, {a: Fixnum, b: String}).should eql true
    HashVerifier.verify({a: 1, b: "Sup"}, {a: Object, b: Object}).should eql true

    HashVerifier.verify({a: 1, b: "Sup", c: []}, {a: 1, b: String, c: Array}).should eql true
    HashVerifier.verify({a: 1, b: "Sup", c: [1], d: ["Sup", []]}, {a: 1, b: String, c: [Fixnum], d:[String, Array]}).should eql true

    expect {
      HashVerifier.verify({a: 1, b: "Sup"}, {a: Object, b: 1})
    }.to raise_error(ValueMismatch)
  end

  it "Should match single value arrays in pattern" do
    HashVerifier.verify({a: []}, {a: [Fixnum]}).should eql true
    HashVerifier.verify({a: [1, 2, 3]}, {a: [Fixnum]}).should eql true
    HashVerifier.verify({a: [1, 2.0, 1]}, {a: [Numeric]}).should eql true
    HashVerifier.verify({a: [1, 2.0, "Sup"]}, {a: [Object]}).should eql true
    HashVerifier.verify({a: [1]}, {a: [1]}).should eql true
    expect {
      HashVerifier.verify({a: [1, 2, 3.0]}, {a: [Fixnum]})
    }.to raise_error(ClassMismatch)
    # Strict
    HashVerifier.strict_verify({a: []}, {a: [Fixnum]}).should eql true
    HashVerifier.strict_verify({a: [1, 2, 3]}, {a: [Fixnum]}).should eql true
    expect {
      HashVerifier.strict_verify({a: [1, 2.0, 1]}, {a: [Numeric]}).should eql true
    }.to raise_error(ClassMismatch)
    expect {
      HashVerifier.strict_verify({a: [1, 2, 3.0]}, {a: [Fixnum]})
    }.to raise_error(ClassMismatch)
  end

  it "should match in array patterns" do
    HashVerifier.verify({a: [1, "Sup"]}, {a: [Fixnum, String]}).should eql true
    HashVerifier.verify({a: [1, "Sup", "Extra"]}, {a: [Fixnum, String]}).should eql true
    HashVerifier.verify({a: [1, "Sup", "Extra"]}, {a: [Fixnum, Object, Object]}).should eql true
    HashVerifier.strict_verify({a: [1, 2]}, {a: [1, 2]}).should eql true
    expect {
      HashVerifier.strict_verify({a: [1, 1]}, {a: [Fixnum, String]})
    }.to raise_error(ClassMismatch)

    # Strict
    HashVerifier.strict_verify({a: [1, "Sup", []]}, {a: [Fixnum, String, Array]}).should eql true
    expect {
      HashVerifier.strict_verify({a: [1, "Sup", "Extra"]}, {a: [Fixnum, String]})
    }.to raise_error(SizeMismatch)
    expect {
      HashVerifier.strict_verify({a: [1, 1]}, {a: [Fixnum, String]})
    }.to raise_error(ClassMismatch)
  end

  it "should support nested hashes" do
     HashVerifier.verify({a: {a: 1}}, {a: {a: 1}}).should eql true
     HashVerifier.verify({a: {a: 1}}, {a: {a: Fixnum}}).should eql true
     HashVerifier.verify({a: {a: ["Sup"]}}, {a: {a: [String]}}).should eql true
     HashVerifier.verify({a: {a: {a: {a:["Sup"]}}}}, {a: {a: {a: {a: [String]}}}}).should eql true
     expect {
       HashVerifier.verify({a: {a: {a: {a:["Sup"]}}}}, {a: {a: {a: {a: [Integer]}}}})
     }.to raise_error(ClassMismatch)
     expect {
       HashVerifier.verify({a: {a: {a: {a: "Sup"}}}}, {a: {a: {a: {a: "Yo"}}}})
     }.to raise_error(ValueMismatch)
  end

end