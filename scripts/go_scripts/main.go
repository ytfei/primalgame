package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"math/big"
	"strconv"
	"strings"

	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
)

var test_network = "https://data-seed-prebsc-1-s1.binance.org:8545"

//var main = ""
var conn *ethclient.Client

func init() {
	var err error
	conn, err = ethclient.Dial(test_network)
	if err != nil {
		panic(err)
	}
}

type hero struct {
	TokenId uint64
	Uri     string
	Name    string
	Rarity  string
}

func main() {
	//
	// 铸造英雄
	// i => 铸造的tokenID
	//for i:=610;i<620;i++{
	//	err := Call(
	//		"",
	//		"mint",
	//		"",
	//		[]interface{}{"",strconv.FormatInt(int64(i),10),"www"},
	//		"tokenabi.json",
	//		"",
	//	)
	//	fmt.Println(err)
	//}

	// 充值到矿池
	// TODO: REPLACE ADDRESS
	EleContracts := []string{
		"WIND_ADDRESS",
		"LIFE_ADDRESS",
		"WATER_ADDRESS",
		"FIRE_ADDRESS",
		"EARTH_ADDRESS",
		"SOURCE_ADDRESS",
	}

	for _, ele := range EleContracts {
		amount, _ := new(big.Int).SetString("10000000000000000000001", 10)
		addr := common.HexToAddress("WIND_ADDRESS")
		err := Call(
			ele,
			"mint",
			"WIND_ADDRESS",
			[]interface{}{addr.String(), amount.String()},
			"erc20token.json",
			"",
		)
		if err != nil {
			fmt.Println(err)
		}
	}
}

func Call(contract string, funcName string, owner string, params []interface{}, abiFile string, ownerPrivate string) error {
	contractAddr := common.HexToAddress(contract)
	ownerAddr := common.HexToAddress(owner)
	nonce, err := conn.PendingNonceAt(context.Background(), ownerAddr)
	if err != nil {
		return err
	}
	gasPrice, err := getGasPrice(conn)
	if err != nil {
		return err
	}
	abi, err := readAbi(abiFile)
	if err != nil {
		return err
	}
	data, err := packAbi(funcName, abi, params)
	if err != nil {
		return err
	}
	gasLimit := uint64(100000 * 40)
	tx := types.NewTransaction(nonce, contractAddr, big.NewInt(0), gasLimit, gasPrice, data)
	privateKey, err := crypto.HexToECDSA(ownerPrivate)
	if err != nil {
		return err
	}
	signedTx, err := types.SignTx(tx, types.HomesteadSigner{}, privateKey)
	if err != nil {
		return err
	}
	err = conn.SendTransaction(context.Background(), signedTx)
	if err != nil {
		return err
	}
	fmt.Println(signedTx.Hash())
	return nil
}

func packAbi(methodName, abistr string, param []interface{}) ([]byte, error) {
	abis, err := abi.JSON(strings.NewReader(abistr))
	if err != nil {
		panic(err)
	}
	method := abis.Methods[methodName]
	if len(method.Inputs) != len(param) {
		return nil, err
	}
	var input []interface{}
	for k, v := range method.Inputs {
		input = append(input, GetParam(param[k], v.Type.String()))
	}
	return abis.Pack(methodName, input...)
}

func GetParam(value interface{}, _type string) interface{} {
	switch _type {
	case "address":
		return common.HexToAddress(value.(string))
	case "uint256":
		//fmt.Println(big.NewInt(StringToInt64(value.(string))))
		amount, _ := new(big.Int).SetString(value.(string), 10)
		return amount
	default:
		return value
	}
}

func getGasPrice(client *ethclient.Client) (*big.Int, error) {
	gasPrice, err := client.SuggestGasPrice(context.Background())
	if err != nil {
		return nil, err
	}
	return gasPrice, nil
}

//string 转 int64
func StringToInt64(input string) int64 {
	res, _ := strconv.ParseInt(input, 10, 64)
	return res
}

func readAbi(fileName string) (string, error) {
	abi, err := ioutil.ReadFile(fileName)
	if err != nil {
		return "", err
	}
	return string(abi), nil
}
