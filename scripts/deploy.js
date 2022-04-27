const hre = require("hardhat");
const fs = require('fs');

async function main() {
  // look for Blog.sol (almost like importing)
  const Blog = await hre.ethers.getContractFactory("Blog");
  const blog = await Blog.deploy("My web3 Blog");

  await blog.deployed();
  console.log("Blog deployed to:", blog.address);

  //write files locally
  fs.writeFileSync('./config.js', `
  export const contractAddress = "${blog.address}"
  export const ownerAddress = "${blog.signer.address}"
  `)

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
