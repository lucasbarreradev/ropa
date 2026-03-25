package com.sistema.repository;

import com.sistema.model.DevolucionItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DevolucionItemRepository extends JpaRepository<DevolucionItem, Long> {
}
