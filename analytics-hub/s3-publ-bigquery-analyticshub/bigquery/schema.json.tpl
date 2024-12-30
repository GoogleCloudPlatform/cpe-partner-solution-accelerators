[
    {
        "name": "timestamp",
        "type": "TIMESTAMP"
    },
    {
        "name": "endpoint",
        "type": "STRING"
    },
    {
        "name": "podcount",
        "type": "INTEGER"
    },
    {
        "name": "container_count",
        "type": "INTEGER"
    },
    {
        "name": "tls_enabled",
        "type": "INTEGER"
    },
    {
        "name": "errorcode",
        "type": "INTEGER",
        "policyTags": {
            "names": [ "${policy_tag_name}" ]
        }
    },
    {
        "name": "latency",
        "type": "FLOAT"
    },
    {
        "name": "is_timeout",
        "type": "INTEGER"
    }
]