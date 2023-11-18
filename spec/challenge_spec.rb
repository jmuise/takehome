# frozen_string_literal: true

require_relative '../challenge'

sample_company = {
  'id' => 2,
  'name' => 'Yellow Mouse Inc.',
  'top_up' => 37,
  'email_status' => true
}

sample_company2 = {
  'id' => 4,
  'name' => 'Yellow Mouse Inc.',
  'top_up' => 37,
  'email_status' => true
}

sample_user = {
  'id' => 33,
  'first_name' => 'Jim',
  'last_name' => 'Jimerson',
  'email' => 'jim.jimerson@test.com',
  'company_id' => 1,
  'email_status' => true,
  'active_status' => true,
  'tokens' => 10
}

sample_user2 = {
  'id' => 44,
  'first_name' => 'Rim',
  'last_name' => 'Rimerson',
  'email' => 'rim.rimerson@test.com',
  'company_id' => 3,
  'email_status' => true,
  'active_status' => true,
  'tokens' => 10
}

inactive_user = {
  'id' => 11,
  'first_name' => 'Tim',
  'last_name' => 'Timerson',
  'email' => 'tim.timerson@test.com',
  'company_id' => 3,
  'email_status' => true,
  'active_status' => false,
  'tokens' => 10
}

sample_user_out = <<~USER
  \t\tJimerson, Jim, jim.jimerson@test.com
  \t\t  Previous Token Balance, 10
  \t\t  New Token Balance 65
USER

sample_users_out = <<~USERS
  \t\tJimerson, Jim, jim.jimerson@test.com
  \t\t  Previous Token Balance, 10
  \t\t  New Token Balance 65
  \t\tRimerson, Rim, rim.rimerson@test.com
  \t\t  Previous Token Balance, 10
  \t\t  New Token Balance 65
USERS

company_with_emailable = <<~EXPECTED

  \tCompany Id: 2
  \tCompany Name: Yellow Mouse Inc.
  \tUsers Emailed:
  \t\tJimerson, Jim, jim.jimerson@test.com
  \t\t  Previous Token Balance, 10
  \t\t  New Token Balance 47
  \tUsers Not Emailed:
  \t\tTotal amount of top ups for Yellow Mouse Inc.: 37
EXPECTED

company_with_nonemailable = <<~EXPECTED

  \tCompany Id: 2
  \tCompany Name: Yellow Mouse Inc.
  \tUsers Emailed:
  \tUsers Not Emailed:
  \t\tJimerson, Jim, jim.jimerson@test.com
  \t\t  Previous Token Balance, 10
  \t\t  New Token Balance 47
  \t\tTotal amount of top ups for Yellow Mouse Inc.: 37
EXPECTED

company_with_multiemail = <<~EXPECTED

  \tCompany Id: 2
  \tCompany Name: Yellow Mouse Inc.
  \tUsers Emailed:
  \t\tRimerson, Rim, rim.rimerson@test.com
  \t\t  Previous Token Balance, 10
  \t\t  New Token Balance 47
  \tUsers Not Emailed:
  \t\tJimerson, Jim, jim.jimerson@test.com
  \t\t  Previous Token Balance, 10
  \t\t  New Token Balance 47
  \t\tTotal amount of top ups for Yellow Mouse Inc.: 74
EXPECTED

company_with_multiemailable = <<~EXPECTED

  \tCompany Id: 2
  \tCompany Name: Yellow Mouse Inc.
  \tUsers Emailed:
  \t\tJimerson, Jim, jim.jimerson@test.com
  \t\t  Previous Token Balance, 10
  \t\t  New Token Balance 47
  \t\tRimerson, Rim, rim.rimerson@test.com
  \t\t  Previous Token Balance, 10
  \t\t  New Token Balance 47
  \tUsers Not Emailed:
  \t\tTotal amount of top ups for Yellow Mouse Inc.: 74
EXPECTED

company_email_active_false = <<~EXPECTED

  \tCompany Id: 3
  \tCompany Name: Yellow Mouse Inc.
  \tUsers Emailed:
  \tUsers Not Emailed:
  \t\tJimerson, Jim, jim.jimerson@test.com
  \t\t  Previous Token Balance, 10
  \t\t  New Token Balance 47
  \t\tRimerson, Rim, rim.rimerson@test.com
  \t\t  Previous Token Balance, 10
  \t\t  New Token Balance 47
  \t\tTotal amount of top ups for Yellow Mouse Inc.: 74
EXPECTED

company_with_inactive = <<~EXPECTED

  \tCompany Id: 2
  \tCompany Name: Yellow Mouse Inc.
  \tUsers Emailed:
  \tUsers Not Emailed:
  \t\tJimerson, Jim, jim.jimerson@test.com
  \t\t  Previous Token Balance, 10
  \t\t  New Token Balance 47
  \t\tTotal amount of top ups for Yellow Mouse Inc.: 37
EXPECTED

RSpec.describe Challenge do
  challenge = described_class.new
  describe '#print_user' do
    context 'with sample user data given' do
      it 'returns a properly formatted user section' do
        result = challenge.print_user(sample_user, 55)
        expect(result).to eq(sample_user_out)
      end

      it 'updates the tokens' do
        challenge = described_class.new
        result = challenge.print_user(sample_user, 45)
        expect(result).to match(/New Token Balance 55/)
      end
    end
  end

  describe '#print_users' do
    it 'sorts users by last_name' do
      result1 = challenge.print_users([sample_user2, sample_user], 55)
      result2 = challenge.print_users([sample_user, sample_user2], 55)
      expect(result1).to eq(result2)
    end

    it 'matches format' do
      result = challenge.print_users([sample_user2, sample_user], 55)
      expect(result).to eq(sample_users_out)
    end
  end

  describe '#print_company' do
    it 'returns nothing if no matching users are given' do
      result = challenge.print_company(sample_company, [])
      expect(result).to eq("\n")
    end

    it 'returns email users in the email spot' do
      email_user = sample_user
      email_user['company_id'] = sample_company['id']
      email_user['email_status'] = true

      result = challenge.print_company(sample_company, [email_user])
      expect(result).to eq(company_with_emailable)
    end

    it 'returns non-email users in the non-email spot' do
      email_user = sample_user
      email_user['company_id'] = sample_company['id']
      email_user['email_status'] = false

      result = challenge.print_company(sample_company, [email_user])
      expect(result).to eq(company_with_nonemailable)
    end

    it 'returns multiple email users in appropriate email spots' do
      email_user = sample_user
      email_user['company_id'] = sample_company['id']
      email_user['email_status'] = false

      result = challenge.print_company(sample_company, [email_user, sample_user2])
      expect(result).to eq(company_with_multiemail)
    end

    it 'returns multiple email users' do
      email_user = sample_user
      email_user['company_id'] = sample_company['id']
      email_user['email_status'] = true

      result = challenge.print_company(sample_company, [email_user, sample_user2])
      expect(result).to eq(company_with_multiemailable)
    end

    it 'ignores inactive users' do
      email_user = sample_user
      email_user['company_id'] = sample_company['id']
      email_user['email_status'] = false

      result = challenge.print_company(sample_company, [email_user, inactive_user])
      expect(result).to eq(company_with_inactive)
    end
  end

  describe '#print' do
    it 'sorts companies by id' do
      sample_company['id'] = 1
      sample_company2['id'] = 3
      result1 = challenge.print([sample_company, sample_company2], [sample_user2, sample_user])
      result2 = challenge.print([sample_company2, sample_company], [sample_user, sample_user2])
      expect(result1).to eq(result2)
    end

    it 'company email_status overrides user email_status' do
      sample_company2['id'] = 3
      sample_company2['email_status'] = false
      sample_user['company_id'] = 3
      result1 = challenge.print([sample_company2], [sample_user2, sample_user])
      expect(result1).to eq(company_email_active_false)
    end

    it 'matches format' do
      result = challenge.print_users([sample_user2, sample_user], 55)
      expect(result).to eq(sample_users_out)
    end
  end
end
