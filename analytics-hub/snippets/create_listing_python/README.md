# Python sample: create_listing_python

1. Create Analytics Hub Exchange if it does not exist
2. Create Analytics Hub Listing if it does not exist
3. Modify Analytics Hub Listing permissions

```
$ python3 ./main.py \
  --project_id ahd-publ-0429c0-vpcsc-ah \
  --location us -exchange_id ahdemo_golang_exchg \
  --listing_id ahdemo_golang_listing \
  --shared_ds projects/ahd-publ-0429c0-bq-shared-ds/datasets/ahdemo_0429c0_shared_ds \
  --restrict_egress \
  --subscriber_iam_member user:user@domain.com \
  --subscription_viewer_iam_member user:user@domain.com
```
