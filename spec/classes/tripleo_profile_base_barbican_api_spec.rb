#
# Copyright (C) 2016 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#

require 'spec_helper'

describe 'tripleo::profile::base::barbican::api' do
  shared_examples_for 'tripleo::profile::base::barbican::api' do
    let(:pre_condition) do
      "class { '::tripleo::profile::base::barbican': step => #{params[:step]} }"
    end

    context 'with step less than 3' do
      let(:params) { { :step => 1 } }

      it 'should do nothing' do
        is_expected.to contain_class('tripleo::profile::base::barbican::api')
        is_expected.to contain_class('tripleo::profile::base::barbican')
        is_expected.to_not contain_class('barbican::api')
        is_expected.to_not contain_class('barbican::api::logging')
        is_expected.to_not contain_class('barbican::keystone::notification')
        is_expected.to_not contain_class('barbican::quota')
        is_expected.to_not contain_class('barbican::wsgi::apache')
      end
    end

    context 'with step 3 on bootstrap node' do
      let(:params) { {
        :step => 3,
        :bootstrap_node => 'node.example.com',
      } }

      it 'should trigger complete configuration' do
        is_expected.to contain_class('tripleo::profile::base::barbican::api')
        is_expected.to contain_class('tripleo::profile::base::barbican')
        is_expected.to contain_class('barbican::db::sync')
        is_expected.to contain_class('barbican::api')
        is_expected.to contain_class('barbican::api::logging')
        is_expected.to contain_class('barbican::keystone::notification')
        is_expected.to contain_class('barbican::quota')
        is_expected.to contain_class('barbican::wsgi::apache')
      end
    end

    context 'with step 3 not on bootstrap node' do
      let(:params) { {
        :step           => 3,
        :bootstrap_node => 'other.example.com',
      } }

      it 'should not trigger any configuration' do
        is_expected.to contain_class('tripleo::profile::base::barbican::api')
        is_expected.to contain_class('tripleo::profile::base::barbican')
        is_expected.to_not contain_class('barbican::db::sync')
        is_expected.to_not contain_class('barbican::api')
        is_expected.to_not contain_class('barbican::api::logging')
        is_expected.to_not contain_class('barbican::keystone::notification')
        is_expected.to_not contain_class('barbican::quota')
        is_expected.to_not contain_class('barbican::wsgi::apache')
      end
    end

    context 'with step 4 not on bootstrap node' do
      let(:params) { {
        :step           => 4,
        :bootstrap_node => 'other.example.com',
      } }

      it 'should trigger complete configuration with out db items' do
        # TODO(aschultz): barbican::api includes this automatically
        #is_expected.to_not contain_class('barbican::db::sync')
        is_expected.to contain_class('barbican::api')
        is_expected.to contain_class('barbican::api::logging')
        is_expected.to contain_class('barbican::keystone::notification')
        is_expected.to contain_class('barbican::quota')
        is_expected.to contain_class('barbican::wsgi::apache')
      end
    end

  end


  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({ :hostname => 'node.example.com' })
      end

      it_behaves_like 'tripleo::profile::base::barbican::api'
    end
  end
end
