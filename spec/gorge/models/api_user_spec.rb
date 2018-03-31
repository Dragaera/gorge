module Gorge
  RSpec.describe APIUser do
    describe '::generate' do
      let(:uuid1) { SecureRandom.uuid }
      let(:uuid2) { SecureRandom.uuid }

      it 'ensures uniqueness of the UUID-based user' do
        allow(SecureRandom).to receive(:uuid).and_return(uuid1, uuid1, uuid2)


        api_user1 = APIUser.generate
        api_user2 = APIUser.generate

        expect(api_user1.user).to eq uuid1
        expect(api_user2.user).to eq uuid2
      end

      it 'sets the description if specified' do
        user = APIUser.generate('foo')
        expect(user.description).to eq 'foo'
      end

      it 'throws an exception if no unique UUID can be generated' do
        allow(SecureRandom).to receive(:uuid).and_return(uuid1)

        APIUser.generate
        expect { APIUser.generate }.to raise_exception(RuntimeError)
      end
    end

    describe '::authenticate' do
      let(:api_user) { create(:api_user) }
      let(:api_user_disabled) { create(:api_user, :disabled) }

      it 'returns the API user if user and token match' do
        # Change to `last_used_at` timestamp seems to mess up equality
        # comparison in a way which a `#refresh` doesn't fix.
        expect(APIUser.authenticate(api_user.user, api_user.token).id).to eq api_user.id
      end

      it 'returns nil if the user does not match' do
        expect(APIUser.authenticate(api_user_disabled.user, api_user.token)).to be_nil
      end

      it 'returns nil if the token does not match' do
        expect(APIUser.authenticate(api_user.user, api_user_disabled.token)).to be_nil
      end

      it 'returns nil if the user is disabled' do
        expect(APIUser.authenticate(api_user_disabled.user, api_user_disabled.token)).to be_nil
      end

      it 'updates the last_used_at timestamp' do
        Timecop.freeze(Time.new(2018, 1, 1)) do
          expect { APIUser.authenticate(api_user.user, api_user.token) }.to change { api_user.refresh.last_used_at }.to(Time.new(2018, 1, 1))
        end
      end
    end
  end
end
