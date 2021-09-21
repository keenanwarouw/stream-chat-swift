//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation

/// Triggered when user status changes (eg. online, offline, away, etc.)
public struct UserPresenceChangedEvent: Event {
    /// The user the status changed for
    public let user: ChatUser
    
    /// The event timestamp
    public let createdAt: Date?
}

struct UserPresenceChangedEventDTO: EventWithPayload {
    let user: UserPayload
    let createdAt: Date
    let payload: Any
    
    init(from response: EventPayload) throws {
        user = try response.value(at: \.user)
        createdAt = try response.value(at: \.createdAt)
        payload = response
    }
    
    func toDomainEvent(session: DatabaseSession) -> Event? {
        guard let userDTO = session.user(id: user.id) else { return nil }
        
        return UserPresenceChangedEvent(
            user: userDTO.asModel(),
            createdAt: createdAt
        )
    }
}

/// Triggered when user is updated
public struct UserUpdatedEvent: Event {
    /// The updated user
    public let user: ChatUser
    
    /// The event timestamp
    public let createdAt: Date?
}

struct UserUpdatedEventDTO: EventWithPayload {
    let user: UserPayload
    let createdAt: Date
    let payload: Any
    
    init(from response: EventPayload) throws {
        user = try response.value(at: \.user)
        createdAt = try response.value(at: \.createdAt)
        payload = response
    }
    
    func toDomainEvent(session: DatabaseSession) -> Event? {
        guard let userDTO = session.user(id: user.id) else { return nil }
        
        return UserUpdatedEvent(
            user: userDTO.asModel(),
            createdAt: createdAt
        )
    }
}

// MARK: - User Watching

/// Triggered when a user starts/stops watching a channel
public struct UserWatchingEvent: ChannelSpecificEvent {
    /// The channel identifier a user started/stopped watching
    public let cid: ChannelId
    
    /// The event timestamp
    public let createdAt: Date
    
    /// The user who started/stopped watching a channel
    public let user: ChatUser
    
    /// The # of channel watchers
    public let watcherCount: Int
    
    /// The flag saying if watching was started or stopped
    public let isStarted: Bool
}

struct UserWatchingEventDTO: EventWithPayload {
    let cid: ChannelId
    let user: UserPayload
    let createdAt: Date
    let watcherCount: Int
    let isStarted: Bool
    let payload: Any
    
    init(from response: EventPayload) throws {
        cid = try response.value(at: \.cid)
        user = try response.value(at: \.user)
        createdAt = try response.value(at: \.createdAt)
        watcherCount = try response.value(at: \.watcherCount)
        isStarted = response.eventType == .userStartWatching
        payload = response
    }
    
    func toDomainEvent(session: DatabaseSession) -> Event? {
        guard let userDTO = session.user(id: user.id) else { return nil }
        
        return UserWatchingEvent(
            cid: cid,
            createdAt: createdAt,
            user: userDTO.asModel(),
            watcherCount: watcherCount,
            isStarted: isStarted
        )
    }
}

// MARK: - User Ban

public struct UserGloballyBannedEvent: UserSpecificEvent {
    var userId: UserId
    var createdAt: Date?
    var payload: Any
    
    init(from response: EventPayload) throws {
        userId = try response.value(at: \.user?.id)
        createdAt = response.createdAt
        payload = response
    }
}

/// Triggered when user is banned in a specific channel
public struct UserBannedEvent: ChannelSpecificEvent {
    /// The channel identifer user is banned at.
    public let cid: ChannelId
    
    /// The banned user.
    public let user: ChatUser
    
    /// The identifier of a user who initiated a ban.
    public let ownerId: UserId
    
    /// The event timestamp
    public let createdAt: Date?
    
    /// The ban reason.
    public let reason: String?
    
    /// The ban expiration date.
    public let expiredAt: Date?
}

struct UserBannedEventDTO: EventWithPayload {
    let cid: ChannelId
    let user: UserPayload
    let ownerId: UserId
    let createdAt: Date
    let reason: String?
    let expiredAt: Date?
    let payload: Any
    
    init(from response: EventPayload) throws {
        cid = try response.value(at: \.cid)
        user = try response.value(at: \.user)
        ownerId = try response.value(at: \.createdBy?.id)
        createdAt = try response.value(at: \.createdAt)
        reason = response.banReason
        expiredAt = response.banExpiredAt
        payload = response
    }
    
    func toDomainEvent(session: DatabaseSession) -> Event? {
        guard let userDTO = session.user(id: user.id) else { return nil }
        
        return UserBannedEvent(
            cid: cid,
            user: userDTO.asModel(),
            ownerId: ownerId,
            createdAt: createdAt,
            reason: reason,
            expiredAt: expiredAt
        )
    }
}

public struct UserGloballyUnbannedEvent: UserSpecificEvent {
    var userId: UserId
    var createdAt: Date?
    var payload: Any
    
    init(from response: EventPayload) throws {
        userId = try response.value(at: \.user?.id)
        createdAt = response.createdAt
        payload = response
    }
}

/// Triggered when banned user is unbanned in a specific channel
public struct UserUnbannedEvent: ChannelSpecificEvent {
    /// The channel identifer user is unbanned at.
    public let cid: ChannelId
    
    /// The unbanned user.
    public let user: ChatUser
    
    /// The event timestamp
    public let createdAt: Date?
}

struct UserUnbannedEventDTO: EventWithPayload {
    let cid: ChannelId
    let user: UserPayload
    let createdAt: Date
    let payload: Any
    
    init(from response: EventPayload) throws {
        cid = try response.value(at: \.cid)
        user = try response.value(at: \.user)
        createdAt = try response.value(at: \.createdAt)
        payload = response
    }
    
    func toDomainEvent(session: DatabaseSession) -> Event? {
        guard let userDTO = session.user(id: user.id) else { return nil }
        
        return UserUnbannedEvent(
            cid: cid,
            user: userDTO.asModel(),
            createdAt: createdAt
        )
    }
}
