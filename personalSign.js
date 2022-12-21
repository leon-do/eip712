async function personalSign() {
  // connect to wallet
  const from = await ethereum.request({ method: "eth_requestAccounts" });
  const message = "hello world";
  const params = [from[0], message];
  const method = "personal_sign";

  web3.currentProvider.sendAsync(
    {
      method,
      params,
      from: from[0],
    },
    function (err, result) {
      if (err) return console.dir(err);
      if (result.error) {
        alert(result.error.message);
      }
      if (result.error) return console.error("ERROR", result);
      console.log("PERSONAL SIGNED:" + JSON.stringify(result.result));
      // display
      document.getElementById("personalSigned").innerHTML = result.result;
    }
  );
}
