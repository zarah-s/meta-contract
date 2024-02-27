import { ethers } from "hardhat";

async function main() {
  // 0x9559A2F8F32AA39813aefe53f865e37966e81e4A

  const meta = await ethers.deployContract("Meta");

  await meta.waitForDeployment();

  console.log(
    `Meta ${meta.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
