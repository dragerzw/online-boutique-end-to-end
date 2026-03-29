# Code Citations

## License: MIT
https://github.com/DFE-Digital/teaching-vacancies/tree/62f59b7d89987ca691bc2be1739e2cf046279b90/.github/workflows/backup_production_db.yml

```
name: Checkout code
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key
```


## License: MIT
https://github.com/somleng/somleng-switch/tree/a45dc8cf36278ec009afe036d4b4708d0f401d36/.github/workflows/media_proxy.yml

```
/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY
```


## License: unknown
https://github.com/anujdevopslearn/MavenBuild/tree/f05d2b76ec17ef7a55d946c6df39e74b3e908df9/.github/workflows/caller.yml

```
uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-
```


## License: unknown
https://github.com/ayodele-ademeso/production-k8s/tree/31e68821e0303b417b29cb7baee38f1b7fa05c93/.github/workflows/terraform-apply.yml

```
with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform
```

