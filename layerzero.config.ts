// eslint-disable-next-line @typescript-eslint/no-var-requires
import { EndpointId } from '@layerzerolabs/lz-definitions'
import { ExecutorOptionType } from "@layerzerolabs/lz-v2-utilities";
import {BigNumber} from "ethers";

const arbsepContract = {
    eid: EndpointId.ARBSEP_V2_TESTNET,
    address: '0x123',
}

const fujiContract = {
    eid: EndpointId.AVALANCHE_V2_TESTNET,
    address: '0x456',
}

const mumbaiContract = {
    eid: EndpointId.POLYGON_V2_TESTNET,
    contractName: 'MyOFTMock'
}

export default {
    contracts: [
        {
            contract: fujiContract,
        },
        {
            contract: arbsepContract,
        },
    ],
    connections: [
        {
            from: fujiContract,
            to: arbsepContract,
            config: {
            },
        },
        {
            from: arbsepContract,
            to: fujiContract,
        },
    ],
}
