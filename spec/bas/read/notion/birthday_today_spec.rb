# frozen_string_literal: true

RSpec.describe Read::Notion::BirthdayToday do
  before do
    @config = {
      database_id: "c17e556d16c84272beb4ee73ab709631",
      secret: "secret_BELfDH6cf4Glc9NLPLxvsvdl9iZVD4qBCyMDXqch51B"
    }

    @read = described_class.new(@config)
  end

  describe "attributes and arguments" do
    it { expect(@read).to respond_to(:config) }

    it { expect(described_class).to respond_to(:new).with(1).arguments }
    it { expect(@read).to respond_to(:execute).with(0).arguments }
  end

  describe ".execute" do
    it "read data from the given configured notion database" do
      VCR.use_cassette("/notion/birthdays/read_with_filter") do
        birthdays_reader = described_class.new(@config)
        read_data = birthdays_reader.execute

        expect(read_data).to be_an_instance_of(Read::Notion::Types::Response)
        expect(read_data.results).to be_an_instance_of(Array)
        expect(read_data.results.length).to eq(1)
      end
    end

    it "read empty data from the given configured notion database" do
      VCR.use_cassette("/notion/birthdays/read_with_empty_database") do
        config = @config
        config[:database_id] = "a3de68d2848a4eceb9418ff6bf44d086"

        birthday_reader = described_class.new(config)
        read_data = birthday_reader.execute

        expect(read_data).to be_an_instance_of(Read::Notion::Types::Response)
        expect(read_data.results).to be_an_instance_of(Array)
        expect(read_data.results.length).to eq(0)
      end
    end

    it "raises an exception caused by invalid database_id provided" do
      VCR.use_cassette("/notion/birthdays/read_with_invalid_database_id") do
        config = @config
        config[:database_id] = "a17e556d16c84272beb4ee73ab709630"
        birthday_reader = described_class.new(@config)

        expected_exception = "Could not find database with ID: c17e556d-16c8-4272-beb4-ee73ab709631. " \
                             "Make sure the relevant pages and databases are shared with your integration."

        expect do
          birthday_reader.execute
        end.to raise_exception(expected_exception)
      end
    end

    it "raise an exception caused by invalid or incorrect api_key provided" do
      VCR.use_cassette("/notion/birthdays/read_with_invalid_api_key") do
        config = @config
        config[:secret] = "secret_ZELfDH6cf4Glc9NLPLxvsvdl9iZVD4qBCyMDXqch51C"
        birthday_reader = described_class.new(config)

        expect { birthday_reader.execute }.to raise_exception("API token is invalid.")
      end
    end
  end
end
