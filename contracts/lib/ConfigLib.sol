// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.25;

import "../DataTypes.sol";
import { AssociatedArrayLib } from "../utils/AssociatedArrayLib.sol";
import "../interfaces/IPolicy.sol";
import "../interfaces/IRegistry.sol";
import { SENTINEL, SentinelList4337Lib } from "sentinellist/SentinelList4337.sol";
import { IdLib } from "./IdLib.sol";

library ConfigLib {
    using SentinelList4337Lib for SentinelList4337Lib.SentinelList;
    using ConfigLib for *;
    using AssociatedArrayLib for *;
    using IdLib for *;

    error UnsupportedPolicy(address policy);

    event PolicyEnabled(SignerId signerId, address policy, address smartAccount);

    IRegistry internal constant registry = IRegistry(0x000000000069E2a187AEFFb852bF3cCdC95151B2);
    ModuleType internal constant POLICY_MODULE_TYPE = ModuleType.wrap(7);

    /**
     * Generic function to enable policies for a signerId
     */
    function enable(
        Policy storage $policy,
        SignerId signerId,
        SessionId sessionId,
        PolicyData[] memory policyDatas,
        address smartAccount,
        bool useRegistry
    )
        internal
    {
        // iterage over all policyData
        uint256 lengthConfigs = policyDatas.length;
        for (uint256 i; i < lengthConfigs; i++) {
            PolicyData memory policyData = policyDatas[i];

            ISubPermission policy = ISubPermission(policyData.policy);
            if (!policy.supportsInterface(type(ISubPermission).interfaceId)) revert UnsupportedPolicy(address(policy));

            if (useRegistry) registry.checkForAccount(smartAccount, address(policy), POLICY_MODULE_TYPE);

            ISubPermission(policy).onInstall({ data: abi.encodePacked(sessionId, smartAccount, policyData.initData) });

            $policy.policyList[signerId].safePush(smartAccount, address(policy));
            emit PolicyEnabled(signerId, address(policy), smartAccount);
        }
    }

    function enable(
        EnumerableActionPolicy storage $self,
        SignerId signerId,
        ActionData[] memory actionPolicyDatas,
        address smartAccount,
        bool useRegistry
    )
        internal
    {
        uint256 length = actionPolicyDatas.length;
        for (uint256 i; i < length; i++) {
            // record every enabled actionId
            ActionData memory actionPolicyData = actionPolicyDatas[i];
            ActionId actionId = actionPolicyData.actionId;
            // TODO: It is currently possible to push the same actionId several times
            // won't be easy to clean. Introduce 'contains' check before pushing
            $self.enabledActionIds[signerId].push(smartAccount, ActionId.unwrap(actionId));
            SessionId sessionId = signerId.toSessionId(actionId);
            $self.actionPolicies[actionId].enable(
                signerId, sessionId, actionPolicyData.actionPolicies, smartAccount, useRegistry
            );
        }
    }

    function disable(SentinelList4337Lib.SentinelList storage $self, SessionId _sessionId, address account) internal {
        (address[] memory entries,) = $self.getEntriesPaginated(account, SENTINEL, 32);

        uint256 length = entries.length;
        for (uint256 i; i < length; i++) {
            address entry = entries[i];
            // TODO: use try catch to prevent dos
            // ISubPermission(entry).deinitForAccount(account, _sessionId);
            ISubPermission(entry).onUninstall(abi.encodePacked(_sessionId, account));
        }

        $self.popAll(account);
    }
}
