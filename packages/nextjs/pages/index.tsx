import Image from "next/image";
import type { NextPage } from "next";
import { MetaHeader } from "~~/components/MetaHeader";

const Home: NextPage = () => {
  return (
    <>
      <MetaHeader />
      <div className="flex flex-col items-center">
        <div className="px-5 max-w-3xl">
          <div className="mt-14 mb-8">
            <h1 className="text-center mb-3 text-3xl">DeFi Challenge #2</h1>
            <h2 className="text-center text-4xl font-semibold">🍷SOMMELIER ERC4626 ADAPTOR</h2>
          </div>
          <div className="flex justify-center mb-10">
            <Image
              alt="wine cellar pixel art"
              src="/somm.png"
              width="800"
              height="400"
              className="rounded-xl border-4 border-primary"
            />
          </div>
          <div className="text-xl text-center">
            <p>
              This challenge guides students through the smart contract architecture of Sommelier Finance and how to
              write an adaptor contract that allows defi strategists to allocate assets from a Sommelier cellar into the
              Aura Protocol.
            </p>
          </div>
        </div>
      </div>
    </>
  );
};

export default Home;
