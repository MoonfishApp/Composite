pragma solidity ^0.4.24;

contract <#__project_name#> {

    /**
    @notice Submit off-chain game state proof
    @param _stateproof is serialized off-chain state
    @param _signatures is serialized signatures
    */
    function intendSettle(bytes _stateproof, bytes _signatures) {
        <#off-chain state#>
    }


    /**
    @notice Confirm off-chain state is settled and update on-chain states
    */
    function confirmSettle() {
        <#Update on-chain state#>
    }


    /**
    @notice Check if the game is finalized
    @param _query is query data (empty in Gomoku game)
    @param _timeout is deadline (block number) for the game to be finalized
    @return true if game is finalized before given timeout
    */
    function isFinalized(bytes _query, uint _timeout) public view returns (bool) {

        return <#is done#>
    }


    /**
    @notice Query the game result
    @param _query is query data (player address in Gomoku game)
    @return true if given player wins
    */
    function queryResult(bytes _query) public view returns (bool) {

        return <#did win#>

    }


    /**
    @notice Get the deadline of off-chain state settle
    @return block number of the settle deadline
    */
    function getSettleTime() public view returns (uint) {

        return <#block number#>

    }
}
