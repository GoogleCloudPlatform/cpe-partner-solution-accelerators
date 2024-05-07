# -*- coding: utf-8 -*-
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import streamlit as st
import os

def submit_to_firestore(subscriber_email: str, subscriber_project_number: str):
    import time
    import datetime

    from google.cloud import firestore

    db = firestore.Client(project="isv-coe-predy-00", database="ahsubscribers")
    current_time_millis = int(round(time.time() * 1000))
    current_time_iso = datetime.datetime.now().isoformat()
    data = {
      "time_millis": current_time_millis,
      "time_iso": current_time_iso,
      "subscriber_email": subscriber_email,
      "subscriber_project_number": subscriber_project_number,
      "state": "NEW"
      }
    db.collection("access_requests").document(f"{current_time_millis}#{subscriber_email}").set(data)

def main(environment_name: str = None, project_id: str = None, database: str = 'ahsubscribers'):
  st.title('Analytics Hub Demo')
  st.header('Submit subscription request')
  if environment_name:
    st.subheader(f"Environment: {environment_name}")

  subscribe_form = st.form("subscribe_form", clear_on_submit=False)
  with subscribe_form:
    subscriber_email = st.text_input('''Subscriber e-mail address

  This user will get access to add the linked dataset to the target project.''', key='subscriber_email')

    subscriber_project_number = st.text_input('''Subscriber project number

  This project will be allowed to add the linked dataset. 
  The project number is show in Cloud Console Dashboard, or 
  the `gcloud projects describe [project_id]` gcloud command 
  can be used to get the project number.''', key='subscriber_project_number')

    st.write('''Data handling / data processing policy

  Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
  Ut neque augue, sodales eu suscipit ac, venenatis nec sapien. 
  Praesent gravida, mauris eget porta viverra, mi nunc tempor ex, 
  gravida aliquam dui erat at lacus. Donec nec sollicitudin justo, 
  sed commodo sapien. Sed felis urna, tempor nec molestie ac, 
  pellentesque eu magna. Nulla vitae massa accumsan, blandit erat 
  vitae, pretium enim. Aenean fermentum ligula vitae luctus dignissim. 
  Suspendisse eleifend vulputate nulla et finibus. 
  Sed vulputate ipsum nulla, vel vestibulum tellus porttitor in.
    ''')
    data_policy_accepted = st.checkbox('Consent to data the policy', key='accept_dp')

    submit = st.form_submit_button('Send access request')

  status_text = st.text('')

  if submit:
      import validators

      errors = []
      if not validators.email(subscriber_email):
        errors.append('Please enter a valid e-mail address.')
      if not subscriber_project_number.isnumeric():
        errors.append('Please enter a valid project number.')
      if not data_policy_accepted:
        errors.append('Please accept the data handling policy.')
      
      if len(errors) == 0:
        submit_to_firestore(subscriber_email, subscriber_project_number)
        st.success('Your access request has been submitted!', icon="✅")
      else:
        for error in errors:
          st.error(f'Error: {error}')

if __name__ == '__main__':
  if 'DEMO_TITLE' in os.environ:
    demo_title = os.environ['DEMO_TITLE']
  else:
    demo_title = ''
  if 'PROJECT_ID' in os.environ:
    project_id = os.environ['PROJECT_ID']
  else:
    print('PROJECT_ID environment variable must be defined')
    os.exit()
  if 'DATABASE' in os.environ:
    database = os.environ['DATABASE']
  else:
    print('DATABASE environment variable must be defined')
    os.exit()

  main(environment_name = demo_title, project_id = project_id, database = database)
