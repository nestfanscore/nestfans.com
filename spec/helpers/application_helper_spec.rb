require 'rails_helper'

describe ApplicationHelper, type: :helper do
  it 'sanitize_markdown' do
    expect(helper.sanitize_markdown('<a href="javascript:alert()">link</a>')).to eq('<a>link</a>')
  end

  it 'formats the flash messages' do
    expect(helper.notice_message).to eq('')
    expect(helper.notice_message.html_safe?).to eq(true)

    controller.flash[:notice] = 'hello'
    expect(helper.notice_message).to eq('<div class="alert alert-success"><a class="close" data-dismiss="alert" href="#"><i class="fa fa-close"></i></a>hello</div>')
    controller.flash[:notice] = nil

    controller.flash[:warning] = 'hello'
    expect(helper.notice_message).to eq('<div class="alert alert-warning"><a class="close" data-dismiss="alert" href="#"><i class="fa fa-close"></i></a>hello</div>')
    controller.flash[:warning] = nil

    controller.flash[:alert] = 'hello'
    expect(helper.notice_message).to eq('<div class="alert alert-danger"><a class="close" data-dismiss="alert" href="#"><i class="fa fa-close"></i></a>hello</div>')
    controller.flash[:alert] = nil

    controller.flash[:error] = 'hello'
    expect(helper.notice_message).to eq('<div class="alert alert-error"><a class="close" data-dismiss="alert" href="#"><i class="fa fa-close"></i></a>hello</div>')
    controller.flash[:error] = nil
  end

  describe 'admin?' do
    let(:user) { create :user }
    let(:admin) { create :admin }

    it 'knows you are not an admin' do
      expect(helper.admin?(user)).to be_falsey
    end

    it 'knows who is the boss' do
      expect(helper.admin?(admin)).to be_truthy
    end

    it 'use current_user if user not given' do
      allow(helper).to receive(:current_user).and_return(admin)
      expect(helper.admin?(nil)).to be_truthy
    end

    it 'use current_user if user not given a user' do
      allow(helper).to receive(:current_user).and_return(user)
      expect(helper.admin?(nil)).to be_falsey
    end

    it 'know you are not an admin if current_user not present and user param is not given' do
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.admin?(nil)).to be_falsey
    end
  end

  describe 'wiki_editor?' do
    let(:non_editor) { create :non_wiki_editor }
    let(:editor) { create :wiki_editor }

    it 'knows non editor is not wiki editor' do
      expect(helper.wiki_editor?(non_editor)).to be_falsey
    end

    it 'knows wiki editor is wiki editor' do
      expect(helper.wiki_editor?(editor)).to be_truthy
    end

    it 'use current_user if user not given' do
      allow(helper).to receive(:current_user).and_return(editor)
      expect(helper.wiki_editor?(nil)).to be_truthy
    end

    it 'know you are not an wiki editor if current_user not present and user param is not given' do
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.wiki_editor?(nil)).to be_falsey
    end
  end

  describe 'owner?' do
    require 'ostruct'
    let(:user) { create :user }
    let(:user2) { create :user }
    let(:item) { OpenStruct.new user_id: user.id }

    it 'knows who is owner' do
      expect(helper.owner?(nil)).to be_falsey

      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.owner?(item)).to be_falsey

      allow(helper).to receive(:current_user).and_return(user)
      expect(helper.owner?(item)).to be_truthy

      allow(helper).to receive(:current_user).and_return(user2)
      expect(helper.owner?(item)).to be_falsey
    end
  end

  describe 'timeago' do
    it 'should work' do
      t = Time.now
      expect(helper.timeago(t, class: 'foo')).to eq "<abbr class=\"foo timeago\" title=\"#{t.iso8601}\"></abbr>"
    end
  end

  describe 'insert_code_menu_items_tag' do
    it 'should work' do
      expect(helper.insert_code_menu_items_tag).to include('data-lang="ruby"')
    end
  end
end
