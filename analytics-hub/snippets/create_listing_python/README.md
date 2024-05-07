# Python sample: create_listing_python

1. Create Analytics Hub Exchange if it does not exist
2. Create Analytics Hub Listing if it does not exist
3. Modify Analytics Hub Listing permissions

```
$ python3 ./main.py \
  ahd-publ-0429c0-vpcsc-ah \
  us \
  ahdemo_python_exchg \
  ahdemo_python_listing \
  projects/ahd-publ-0429c0-bq-shared-ds/datasets/ahdemo_0429c0_shared_ds \
  user:user@domain.com
```
