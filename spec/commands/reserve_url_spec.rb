require "rails_helper"

RSpec.describe Commands::ReserveUrl do
  describe "call" do
    context "with a new base_path" do
      let(:payload) {
        { base_path: "/foo", publishing_app: "Foo" }
      }

      it "successfully reserves the path" do
        expect(described_class.call(payload)).to be_a Commands::Success
      end
    end

    context "with an invalid payload" do
      it "returns a CommandError" do
        expect {
          described_class.call({ base_path: "///" })
        }.to raise_error CommandError
      end
    end
  end
end
