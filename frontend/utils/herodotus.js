const submitBatchQuery = async (block) => {
  const apiKey = "4b086c8b-6eda-48b6-909c-3fef441ea155";
  const url = `https://api.herodotus.cloud/submit-batch-query?apiKey=${apiKey}`;
  const body = {
    destinationChainId: "SN_SEPOLIA",
    fee: "0",
    data: {
      11155111: {
        [`block:${block}`]: {
          header: ["BASE_FEE_PER_GAS"],
        },
      },
    },
    webhook: {
      url: "https://webhook.site/1f3a9b5d-5c8c-4e2a-9d7e-6c3c5a0a0e2f",
      headers: {
        "Content-Type": "application/json",
      },
    },
  };

  try {
    const response = await fetch(url, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });
    if (!response.ok) throw new Error("Network response was not ok.");
    const data = await response.json();
    console.log(data);
    // TODO set herodotusQueryId
    return data;
  } catch (error) {
    console.error("There was a problem with the fetch operation:", error);
  }
};

const submitProof = async (block) => {
  fetch(
    `https://ds-indexer.api.herodotus.cloud/mmr-inclusion-proof?deployed_on_chain=SN_SEPOLIA&accumulates_chain=11155111&block_numbers=${block}&from_one_tree=true&hashing_function=poseidon&whole_tree=false&contract_type=Accumulator`,
    {
      method: "GET", // The method is GET
      headers: {
        accept: "application/json", // Set the Accept header to expect JSON response
      },
    }
  )
    .then((response) => {
      if (!response.ok) {
        throw new Error("Network response was not ok");
      }
      return response.json(); // Parse the JSON of the response
    })
    .then((data) => {
      console.log(data); // Log the data
    })
    .catch((error) => {
      console.error(
        "There has been a problem with your fetch operation:",
        error
      );
    });
};

function callUntilTrue(blockNumber) {
  submitProof(blockNumber)
    .then((result) => {
      if (result) {
        console.log("Success:", result);
      } else {
        console.log("Retrying...");
        setTimeout(() => callUntilTrue(blockNumber), 200000); // Wait for 2 seconds before retrying
      }
    })
    .catch((error) => {
      console.error("Error in submitProof:", error);
      setTimeout(() => callUntilTrue(blockNumber), 200000); // Wait and retry upon error as well
    });
}

submitBatchQuery(5369344);
callUntilTrue(5369344);
