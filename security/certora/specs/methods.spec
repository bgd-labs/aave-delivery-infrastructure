

//Commonly used methods
methods{
  function owner() external returns (address) envfree;
  function guardian() external returns (address) envfree;
  function getValidityTimestamp(uint256) external returns (uint120) envfree;
}
