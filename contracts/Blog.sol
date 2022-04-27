//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Blog {
    // name
    string public name;
    //contract
    address public owner;

    using Counters for Counters.Counter;
    Counters.Counter private _postIds;
    
    // 'structure' of post
    struct Post {
        uint id;
        string title;
        // will refer to the IPFS
        string content;
        bool published;
    }

    //way to look up posts, either by post id or hash
    mapping(uint => Post) private idToPost;
    mapping(string => Post) private hashToPost;

    // events, listeners for updats on graphql
    event PostCreated(uint id, string title, string hash);
    event PostUpdated(uint id, string title, string hash, bool published);

    constructor(string memory _name){
        console.log("Deploying Blog with name:", _name);
        name = _name;
        owner = msg.sender;
    }
    function updateName(string memory _name) public {
        name = _name;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    // fetch single post by hash
    function fetchPost(string memory hash) public view returns(Post memory) {
        return hashToPost[hash];
    }
    // creating a post
    function createPost(string memory title, string memory hash) public onlyOwner {
        _postIds.increment();
        uint postId = _postIds.current();
        Post storage post = idToPost[postId];
        post.id = postId;
        post.title = title;
        post.published = true;
        post.content = hash;
        hashToPost[hash] = post;
        emit PostCreated(postId, title, hash);
    }
    // updating a post
    function updatePost(uint postId, string memory title, string memory hash, bool published) public onlyOwner {
        Post storage post = idToPost[postId];
        post.title = title;
        post.published = published;
        post.content = hash;
        idToPost[postId] = post;
        hashToPost[hash] = post;
        emit PostUpdated(post.id, title, hash, published);
    }
    // fetch all posts
    function fetchPosts() public view returns (Post[] memory) {
        // used to determine length for array which is necessary 
        uint itemCount = _postIds.current();
        Post[] memory posts = new Post[](itemCount);
        for(uint i = 0; i < itemCount; i++){
            uint currentId = i + 1;
            Post storage currentItem = idToPost[currentId];
            posts[i] = currentItem;
        }
        return posts;
    }

}
