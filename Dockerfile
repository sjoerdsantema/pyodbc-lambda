# Use Amazon Linux 2 as the base image to match AWS Lambda's environment
FROM public.ecr.aws/lambda/python:3.10
RUN yum update -y && \
    yum install -y \
    gcc \
    python3 \
    unixODBC \
    unixODBC-devel \
    yum clean all

RUN curl https://packages.microsoft.com/config/rhel/8/prod.repo | tee /etc/yum.repos.d/mssql-release.repo && \
    ACCEPT_EULA=Y yum install -y msodbcsql18 && \
    ACCEPT_EULA=Y yum install -y mssql-tools18 && \
    yum install -y unixODBC-devel

RUN curl -o rds-combined-ca-bundle.pem https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
RUN curl -o rds-eu-west-1-ca-bundle.pem https://truststore.pki.rds.amazonaws.com/eu-west-1/eu-west-1-bundle.pem

RUN python3 -m pip install pyodbc

# Copy function code
COPY . ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "etc_gms_custom_resource.on_event" ]
