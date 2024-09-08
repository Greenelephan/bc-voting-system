import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { VoterRegistration } from "../target/types/voter_registration";

describe("voter_registration", () => {
  anchor.setProvider(anchor.AnchorProvider.env());

  const program = anchor.workspace.SmartContracts as Program<VoterRegistration>;
});
