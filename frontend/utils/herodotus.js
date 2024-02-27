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
    `https://rs-indexer.api.herodotus.cloud/accumulators/mmr-meta-and-proof?deployed_on_chain=11155111&accumulates_chain=11155111&block_numbers=${block}&hashing_function=keccak&contract_type=AGGREGATOR`,
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
      const block_number = data.data[0].proofs[0].block_number;
      const index = data.data[0].proofs[0].element_index;
      const block_header = data.data[0].proofs[0].rlp_block_header;
      const peaks = data.data[0].meta.mmr_peaks;
      const proof = 0;
      const mmr_id = data.data[0].meta.mmr_id;

      console.log("block number:", block_number);
      console.log("index:", index);
      console.log("block header:", block_header);
      console.log("peaks:", peaks);
      console.log("proof:", proof);
      console.log("mmr id:", mmr_id);

      //console.log("meta:", data.data[0].meta);
      console.log("proofs:", data.data[0].proofs);
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
        setTimeout(() => callUntilTrue(blockNumber), 20000); // Wait for 2 seconds before retrying
      }
    })
    .catch((error) => {
      console.error("Error in submitProof:", error);
      setTimeout(() => callUntilTrue(blockNumber), 20000); // Wait and retry upon error as well
    });
}

submitBatchQuery(5369344);
callUntilTrue(5369344);
