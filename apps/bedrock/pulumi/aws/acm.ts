import * as aws from '@pulumi/aws';
import { zones } from '$aws/route53';

const createCertificate = (domain: string) => {
  const certificate = new aws.acm.Certificate(domain, {
    domainName: domain,
    subjectAlternativeNames: [`*.${domain}`],
    validationMethod: 'DNS',
  });

  certificate.domainValidationOptions.apply((options) => {
    for (const option of options) {
      if (option.domainName !== domain) {
        continue;
      }

      const name = option.resourceRecordName.slice(0, -1);

      new aws.route53.Record(name, {
        zoneId: zones[domain.replaceAll('.', '_') as keyof typeof zones].zoneId,
        type: option.resourceRecordType,
        name,
        records: [option.resourceRecordValue.slice(0, -1)],
        ttl: 300,
      });
    }
  });

  new aws.acm.CertificateValidation(domain, {
    certificateArn: certificate.arn,
  });

  return certificate;
};

export const certificates = {
  pencil_so: createCertificate('pencil.so'),
  penxle_com: createCertificate('penxle.com'),
  penxle_io: createCertificate('penxle.io'),
  pnxl_cc: createCertificate('pnxl.cc'),
  pnxl_co: createCertificate('pnxl.co'),
  pnxl_me: createCertificate('pnxl.me'),
  pnxl_net: createCertificate('pnxl.net'),
  pnxl_site: createCertificate('pnxl.site'),
};

export const outputs = {
  AWS_ACM_PENCIL_SO_CERTIFICATE_ARN: certificates.pencil_so.arn,
  AWS_ACM_PENXLE_COM_CERTIFICATE_ARN: certificates.penxle_com.arn,
  AWS_ACM_PENXLE_IO_CERTIFICATE_ARN: certificates.penxle_io.arn,
  AWS_ACM_PNXL_CC_CERTIFICATE_ARN: certificates.pnxl_cc.arn,
  AWS_ACM_PNXL_CO_CERTIFICATE_ARN: certificates.pnxl_co.arn,
  AWS_ACM_PNXL_ME_CERTIFICATE_ARN: certificates.pnxl_me.arn,
  AWS_ACM_PNXL_NET_CERTIFICATE_ARN: certificates.pnxl_net.arn,
  AWS_ACM_PNXL_SITE_CERTIFICATE_ARN: certificates.pnxl_site.arn,
};
