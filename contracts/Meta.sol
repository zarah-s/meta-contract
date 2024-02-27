// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./ERC721.sol";

contract Meta {
    address owner;
    uint groupCount;
    uint postCount;
    Post[] posts;
    uint deletedPostsCount;
    mapping(uint => uint) deletedGroupPostsCount;
    mapping(address => uint) tokenCount;
    mapping(address => User) users;
    mapping(uint => Group) groups;
    mapping(address => NFT) nfts;

    struct Post {
        address tokenAddress;
        uint id;
        uint tokenId;
        string tokenUri;
        string title;
        string description;
        address author;
        bool deleted;
        bool valid;
    }

    struct Group {
        bool valid;
        uint id;
        address tokenAddress;
        address owner;
        string name;
        string description;
        Post[] posts;
    }

    struct User {
        address id;
        string name;
        bool authenticated;
    }

    modifier OnlyOwner() {
        require(msg.sender == owner, "NOT OWNER");
        _;
    }

    modifier CheckUserExist() {
        require(users[msg.sender].authenticated, "UNAUTHORIZED");
        _;
    }

    modifier TokenAddressExist(address _addr) {
        require(address(nfts[_addr]) != address(0), "INVALID TOKEN ADDRESS");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createNFT(
        string calldata _symbol,
        string calldata _name
    ) external OnlyOwner returns (address) {
        NFT newNFT = new NFT(_symbol, _name);
        nfts[address(newNFT)] = newNFT;
        return address(newNFT);
    }

    function signUp(string calldata _name) external {
        User storage newUser = users[msg.sender];
        require(!newUser.authenticated, "ACCOUNT REGISTERED");
        newUser.id = msg.sender;
        newUser.authenticated = true;
        newUser.name = _name;
    }

    function createPost(
        address tokenAddress,
        string calldata title,
        string calldata description,
        string calldata tokenUri
    ) external CheckUserExist TokenAddressExist(tokenAddress) {
        postCount++;
        tokenCount[tokenAddress] += 1;
        nfts[tokenAddress].mint(tokenCount[tokenAddress], tokenUri);
        posts.push(
            Post({
                tokenAddress: tokenAddress,
                id: postCount,
                tokenId: tokenCount[tokenAddress],
                title: title,
                description: description,
                author: msg.sender,
                tokenUri: tokenUri,
                deleted: false,
                valid: true
            })
        );
    }

    function createGroup(
        address tokenAddress,
        string calldata groupName,
        string calldata description
    ) external {
        groupCount++;
        Group storage newGroup = groups[groupCount];
        newGroup.description = description;
        newGroup.description = groupName;
        newGroup.id = groupCount;
        newGroup.owner = msg.sender;
        newGroup.valid = true;
        newGroup.tokenAddress = tokenAddress;
    }

    function createGroupPost(
        address tokenAddress,
        string calldata title,
        string calldata description,
        string calldata tokenUri,
        uint groupId
    ) external CheckUserExist TokenAddressExist(tokenAddress) {
        Group storage group = groups[groupId];
        require(group.valid, "NOT A VALID GROUP");
        require(group.tokenAddress == tokenAddress, "NOT A VALID GROUP");
        tokenCount[tokenAddress] += 1;
        nfts[tokenAddress].mint(tokenCount[tokenAddress], tokenUri);
        Post memory newPost = Post({
            tokenAddress: tokenAddress,
            id: group.posts.length + 1,
            tokenId: tokenCount[tokenAddress],
            title: title,
            description: description,
            author: msg.sender,
            tokenUri: tokenUri,
            deleted: false,
            valid: true
        });
        group.posts.push(newPost);
    }

    function editPost(
        address tokenAddress,
        uint postId,
        string calldata title,
        string calldata description
    ) external {
        Post storage _post = posts[postId - 1];
        require(_post.valid, "INVALID POST");
        require(
            _post.author == msg.sender && _post.tokenAddress == tokenAddress,
            "UNAUTHORIZED"
        );
        _post.title = title;
        _post.description = description;
    }

    function deletePost(address tokenAddress, uint postId) external {
        Post storage _post = posts[postId - 1];
        require(_post.valid, "INVALID POST");
        require(
            _post.author == msg.sender && _post.tokenAddress == tokenAddress,
            "UNAUTHORIZED"
        );
        _post.deleted = true;
    }

    /*



    // function editGroupPost(address tokenAddress,uint postId,uint groupId, string calldata title, string calldata description ) external {
    //     require(groups[groupId].valid,"NOT A VALID GROUP");
    //     Post storage _post = groups[groupId].posts[postId-1];
    //     require(_post.valid,"INVALID POST");
    //     require(_post.author == msg.sender&&_post.tokenAddress == tokenAddress,"UNAUTHORIZED");
    //     _post.title = title;
    //     _post.description = description;       
    // }



    // function deleteGroupPost(address tokenAddress,uint postId,uint groupId ) external {
    //   Post storage _post = groups[groupId].posts[postId-1];
    //     require(_post.valid,"INVALID POST");
    //     require(_post.author == msg.sender&&_post.tokenAddress == tokenAddress,"UNAUTHORIZED");
    //     _post.deleted = true;
    // }


*/

    function getPosts() external view returns (Post[] memory) {
        Post[] memory _posts = new Post[](posts.length - deletedPostsCount);

        for (uint i; i < posts.length; i++) {
            if (!posts[i].deleted) {
                _posts[_posts.length] = posts[i];
            }
        }

        return _posts;
    }

    function getGroupPosts(uint groupId) external view returns (Post[] memory) {
        Group memory _group = groups[groupId];
        require(_group.valid, "NOT A VALID GROUP ID");
        Post[] memory _posts = new Post[](
            _group.posts.length - deletedGroupPostsCount[groupId]
        );
        for (uint i; i < _group.posts.length; i++) {
            if (!_group.posts[i].deleted) {
                _posts[_posts.length] = _group.posts[i];
            }
        }

        return _posts;
    }
}
