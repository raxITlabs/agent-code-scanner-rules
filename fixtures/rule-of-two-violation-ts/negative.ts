// Only one leg (sensitive read). Not the trifecta.
function governed(_resource: string, _gov: unknown, body: (a: any) => string) { return body; }
export function buildTools(gov: unknown) {
  return {
    read_customer: { execute: governed("stripe.customers.read", gov, (a) => `${a.customer_id}`) },
  };
}
