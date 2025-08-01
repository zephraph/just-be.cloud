import alchemy from "npm:alchemy";
import { Zone, DnsRecords } from "npm:alchemy/cloudflare";
import { Exec } from "npm:alchemy/os";

const app = await alchemy("just-be.cloud");

await Exec("deploy", {
  command: "bash ./.scripts/deploy.sh",
});

// Get droplet IP with a separate command
const getDropletIP = await Exec("get-droplet-ip", {
  command: "mise run get-ip",
  inheritStdio: false,
});

const dropletIP = getDropletIP.stdout?.trim();

if (!dropletIP) {
  console.error({ dropletIP });
  throw new Error("❌ No smallweb droplet found. Run deployment first.");
}
console.log(`🌐 Setting up DNS for just-be.cloud zone with IP: ${dropletIP}`);

// Configure Cloudflare zone
const zone = await Zone("just-be.cloud", {
  name: "just-be.cloud",
});

await DnsRecords("just-be-cloud-dns", {
  zoneId: zone.id,
  records: [
    {
      type: "A",
      name: "@",
      content: dropletIP,
      ttl: 1,
      proxied: true,
    },
    {
      type: "A",
      name: "*",
      content: dropletIP,
      ttl: 1,
      proxied: true,
    },
  ],
});

await app.finalize();
