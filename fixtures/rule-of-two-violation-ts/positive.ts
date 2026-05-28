// A single module that ingests untrusted content, reads sensitive data, and
// sends externally — the lethal trifecta.
function governed(_resource: string, _gov: unknown, body: (a: any) => string) { return body; }
export function buildTools(gov: unknown) {
  return {
    read_invoice: { execute: governed("vendor.invoice.read", gov, (a) => `${a.invoice_id}`) },
    read_customer: { execute: governed("stripe.customers.read", gov, (a) => `${a.customer_id}`) },
    send_email: { execute: governed("send_email", gov, (a) => `${a.to}`) },
  };
}
